# Project Formatting Rules

These rules define how to format and edit code in this repository.

## Scope

- Apply these rules to all new and modified files.
- Do not mass-reformat untouched files.
- Preserve existing behavior while formatting.

## Baseline Rules (All Files)

- Use UTF-8 encoding.
- Use LF line endings.
- End every file with a trailing newline.
- Remove trailing whitespace, except when Markdown needs it intentionally.

## Structure and Comments

- Use clear section headers for larger shell files:
  - `# ---[ SECTION NAME ]----------------------------------------------------------`
- Keep comments short and practical.
- Prefer sentence case in comments.
- Keep one blank line between logical blocks.

## Shell Formatting (Primary for this repo)

These rules are based on `.aliases`, `.bashrc`, and `.functions`.

- Shebang:
  - Bash files: `#!/usr/bin/env bash`
  - POSIX sh files: `#!/usr/bin/env sh`
- Keep `shellcheck` directive near the top when needed.
- Function style:
  - Multi-line functions must use:
    - `name() {`
    - body
    - `}`
  - Use one-line functions only for trivial wrappers.
- Indentation:
  - Use 2 spaces for new or edited shell blocks.
  - Do not reindent entire legacy files just to normalize style.
- Conditionals/loops:
  - Prefer `[[ ... ]]` in Bash files.
  - Use `[ ... ]` only for POSIX compatibility.
  - Keep `then`/`do` on the same line when clear; otherwise use a consistent multi-line layout.
- Quoting and expansions:
  - Quote variable expansions by default: `"$var"`, `"${var}"`.
  - Use `${var}` form when concatenating or disambiguating.
- Safety and checks:
  - Use `command -v <cmd> >/dev/null 2>&1` for command checks.
  - Use `read -r` when reading user input.
  - Use `local` for function-local variables in Bash.

## Aliases and Functions

- Group aliases/functions by topic, matching existing section style.
- Keep names descriptive and consistent with existing patterns.
- Add short usage comments for non-obvious functions.
- Prefer readable multi-line logic over dense one-liners.

## Tooling

- Validate shell changes with `shellcheck` when available.
- If using formatters, avoid repo-wide rewrites unless explicitly requested.
