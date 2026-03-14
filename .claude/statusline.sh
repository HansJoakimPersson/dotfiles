#!/usr/bin/env bash

# ---[ HELPERS ]-----------------------------------------------------------------

osc8_link() {
  local url="$1"
  local text="$2"
  printf $'\033]8;;%s\033\\%s\033]8;;\033\\' "$url" "$text"
}

to_https_remote() {
  local remote="$1"
  local url="$remote"

  if [[ "$remote" =~ ^git@([^:]+):(.+)$ ]]; then
    url="https://${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
  elif [[ "$remote" =~ ^ssh://git@([^/]+)/(.+)$ ]]; then
    url="https://${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
  fi

  url="${url%.git}"
  printf '%s' "$url"
}

repo_label_from_remote() {
  local remote="$1"
  local label

  label="$(printf '%s' "$remote" | sed -E 's#^(ssh://)?git@##; s#^https?://##; s#^[^:]+:##; s#^[^/]+/##; s#\.git$##')"
  [[ -z "$label" ]] && label="repo"
  printf '%s' "$label"
}

json_num() {
  local key="$1"
  local data="$2"
  printf '%s' "$data" | tr '\n' ' ' | sed -n 's/.*"'"$key"'"[[:space:]]*:[[:space:]]*\([0-9.]*\).*/\1/p' | head -1
}

json_str() {
  local key="$1"
  local data="$2"
  printf '%s' "$data" | tr '\n' ' ' | sed -n 's/.*"'"$key"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1
}

json_num_in_object() {
  local object_key="$1"
  local key="$2"
  local data="$3"
  printf '%s' "$data" | tr '\n' ' ' | sed -n "s/.*\"${object_key}\"[[:space:]]*:[[:space:]]*{[^}]*\"${key}\"[[:space:]]*:[[:space:]]*\\([0-9.]*\\).*/\\1/p" | head -1
}

json_str_in_object() {
  local object_key="$1"
  local key="$2"
  local data="$3"
  printf '%s' "$data" | tr '\n' ' ' | sed -n "s/.*\"${object_key}\"[[:space:]]*:[[:space:]]*{[^}]*\"${key}\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" | head -1
}

normalize_pct() {
  local value="$1"

  [[ -z "$value" ]] && {
    printf '0'
    return
  }

  awk -v v="$value" 'BEGIN {
    if (v <= 1) {
      printf "%d", (v * 100)
    } else {
      printf "%d", v
    }
  }'
}

normalize_percent_value() {
  local value="$1"
  [[ -z "$value" ]] && {
    printf '0'
    return
  }
  awk -v v="$value" 'BEGIN { printf "%d", v }'
}

normalize_fraction_or_percent() {
  local value="$1"
  [[ -z "$value" ]] && {
    printf '0'
    return
  }
  awk -v v="$value" 'BEGIN {
    if (v < 1) {
      printf "%d", (v * 100)
    } else {
      printf "%d", v
    }
  }'
}

format_pct_or_dash() {
  local value="$1"
  if [[ "$value" =~ ^[0-9]+$ ]]; then
    printf '%s%%' "$value"
  else
    printf '%s' "$value"
  fi
}

# ---[ GIT SEGMENTS ]-------------------------------------------------------------

parse_git_dirty_bits() {
  local repo_path="$1"
  local status
  local bits=""

  status="$(git -C "$repo_path" status --porcelain 2>/dev/null)"

  printf '%s\n' "$status" | grep -q '^R' && bits=">${bits}"
  printf '%s\n' "$status" | grep -q '^ M' && bits="!${bits}"
  printf '%s\n' "$status" | grep -q '^M' && bits="*${bits}"
  printf '%s\n' "$status" | grep -q '^??' && bits="?${bits}"
  printf '%s\n' "$status" | grep -q '^ D' && bits="x${bits}"
  printf '%s\n' "$status" | grep -q '^D' && bits="+${bits}"

  printf '%s' "$bits"
}

cache_key_for_repo() {
  local repo_root="$1"
  if command -v shasum >/dev/null 2>&1; then
    printf '%s' "$repo_root" | shasum | awk '{print $1}'
  elif command -v md5 >/dev/null 2>&1; then
    printf '%s' "$repo_root" | md5 | awk '{print $NF}'
  else
    printf '%s' "$repo_root" | tr '/ ' '__' | tr -cd '[:alnum:]_-.'
  fi
}

cache_is_stale() {
  local file="$1"
  local max_age="$2"
  local mtime

  if [[ ! -f "$file" ]]; then
    return 0
  fi

  if [[ "$OSTYPE" == darwin* ]]; then
    mtime="$(stat -f %m "$file" 2>/dev/null || echo 0)"
  else
    mtime="$(stat -c %Y "$file" 2>/dev/null || echo 0)"
  fi

  [[ $(( $(date +%s) - mtime )) -gt "$max_age" ]]
}

current_dir="${CLAUDE_CODE_CWD:-$PWD}"
repo_segment="-"
branch_segment="-"
git_status_segment="-"

if command -v git >/dev/null 2>&1 && git -C "$current_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  repo_root="$(git -C "$current_dir" rev-parse --show-toplevel 2>/dev/null)"
  git_cache_ttl=5
  git_cache_file="/tmp/claude-statusline-git-$(cache_key_for_repo "$repo_root").cache"

  if cache_is_stale "$git_cache_file" "$git_cache_ttl"; then
    remote_url="$(git -C "$repo_root" config --get remote.origin.url 2>/dev/null)"
    branch_name="$(git -C "$repo_root" symbolic-ref --short -q HEAD 2>/dev/null)"
    dirty_bits="$(parse_git_dirty_bits "$repo_root")"
    printf '%s|%s|%s\n' "$remote_url" "$branch_name" "$dirty_bits" >"$git_cache_file" 2>/dev/null || true
  fi

  if [[ -f "$git_cache_file" ]]; then
    IFS='|' read -r remote_url branch_name dirty_bits <"$git_cache_file"
  fi

  remote_url="${remote_url:-$(git -C "$repo_root" config --get remote.origin.url 2>/dev/null)}"
  branch_name="${branch_name:-$(git -C "$repo_root" symbolic-ref --short -q HEAD 2>/dev/null)}"
  dirty_bits="${dirty_bits:-$(parse_git_dirty_bits "$repo_root")}"

  if [[ -z "$branch_name" ]]; then
    branch_name="$(git -C "$repo_root" rev-parse --short HEAD 2>/dev/null)"
  fi

  if [[ -n "$remote_url" ]]; then
    repo_segment="$(osc8_link "$(to_https_remote "$remote_url")" "$(repo_label_from_remote "$remote_url")")"
  else
    repo_segment="$(basename "$repo_root")"
  fi

  branch_segment="${branch_name:-DETACHED}"
  git_status_segment="${dirty_bits:-clean}"
fi

# ---[ CLAUDE USAGE SEGMENTS ]----------------------------------------------------

# Consume stdin to keep command behavior compatible with Claude statusline execution.
cat >/dev/null

# ---[ 5H USAGE API CACHE ]-------------------------------------------------------

cache_file="/tmp/claude-usage-cache.json"

if [[ "$OSTYPE" == darwin* ]]; then
  age=$(( $(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0) ))
else
  age=$(( $(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0) ))
fi

api=""
stale_api=""
if [[ -f "$cache_file" ]]; then
  stale_api="$(cat "$cache_file" 2>/dev/null)"
fi
if [[ -f "$cache_file" && "$age" -lt 30 ]]; then
  api="$(cat "$cache_file" 2>/dev/null)"
fi

if [[ -z "$api" ]]; then
  creds=""
  if [[ "$OSTYPE" == darwin* ]] && command -v security >/dev/null 2>&1; then
    creds="$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null || true)"
  fi

  if [[ -z "$creds" && -f "$HOME/.claude/.credentials.json" ]]; then
    creds="$(cat "$HOME/.claude/.credentials.json" 2>/dev/null)"
  fi

  token="$(printf '%s' "$creds" | tr '\n' ' ' | sed -n 's/.*"claudeAiOauth"[^}]*"accessToken"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
  if [[ -z "$token" && "$creds" =~ ^[A-Za-z0-9._-]+$ ]]; then
    token="$creds"
  fi

  if [[ -n "$token" ]] && command -v curl >/dev/null 2>&1; then
    api="$(curl -s "https://api.anthropic.com/api/oauth/usage" \
      -H "Authorization: Bearer ${token}" \
      -H "anthropic-beta: oauth-2025-04-20" \
      -H "User-Agent: claude-code/2.0.76" 2>/dev/null)"

    if [[ -n "$api" ]]; then
      printf '%s' "$api" > "$cache_file" 2>/dev/null || true
    fi
  fi
fi

if [[ -z "$api" && -n "$stale_api" ]]; then
  api="$stale_api"
fi

api_flat="$(printf '%s' "$api" | tr '\n' ' ')"
acct_pct_raw="$(json_num_in_object five_hour utilization "$api_flat")"
if [[ -z "$acct_pct_raw" ]]; then
  acct_pct_raw="$(printf '%s' "$api_flat" | sed -n 's/.*"five_hour"[[:space:]]*:[[:space:]]*{[^}]*"utilization"[[:space:]]*:[[:space:]]*{[^}]*"percent"[[:space:]]*:[[:space:]]*\([0-9.]*\).*/\1/p' | head -1)"
fi
if [[ -z "$acct_pct_raw" ]]; then
  acct_pct_raw="$(printf '%s' "$api_flat" | sed -n 's/.*"five_hour"[[:space:]]*:[[:space:]]*{[^}]*"utilization"[[:space:]]*:[[:space:]]*{[^}]*"percentage"[[:space:]]*:[[:space:]]*\([0-9.]*\).*/\1/p' | head -1)"
fi
acct_pct="$(normalize_fraction_or_percent "$acct_pct_raw")"

reset_at="$(printf '%s' "$api_flat" | sed -n 's/.*"five_hour"[[:space:]]*:[[:space:]]*{[^}]*"resets_at"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"

reset_label="--"
if [[ -n "$reset_at" ]]; then
  if [[ "$OSTYPE" == darwin* ]]; then
    reset_epoch="$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "${reset_at:0:19}" +%s 2>/dev/null || echo 0)"
  else
    reset_epoch="$(date -u -d "${reset_at:0:19}" +%s 2>/dev/null || echo 0)"
  fi

  secs=$((reset_epoch - $(date +%s)))
  ((secs < 0)) && secs=0
  reset_label="$((secs / 3600))h$(((secs % 3600) / 60))m"
fi

acct_label="$(format_pct_or_dash "$acct_pct")"

printf '%s | %s | %s | 5h:%s | reset:%s\n' \
  "$repo_segment" \
  "$branch_segment" \
  "$git_status_segment" \
  "$acct_label" \
  "$reset_label"
