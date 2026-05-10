# Project Process Guidelines

- `AGENTS.md` is the authoritative local instruction file.
- User-facing replies use the `caveman` skill unless the user says `stop caveman` or `normal mode`.
- Beads (`bd`) is initialized with prefix `pagebound`; default to creating or claiming a bead before code/docs/config/test/workflow changes. Use `bd prime` for workflow context. Closed setup beads so far: `pagebound-a4p`, `pagebound-444`.
- MCP guidance in `AGENTS.md`: use Godot AI MCP at `http://127.0.0.1:8000/mcp` for live Godot editor work; use Serena for memories and targeted searches, with limited GDScript semantic support; use `rg` and direct reads for GDScript implementation details.
- Git workflow in `AGENTS.md`: use Conventional Commits; do not create branches with the `codex/` prefix; before completion run `git status --short --branch`; summarize changed files and checks not run; update Serena memories when durable project facts change.
- Brooks-Lint guardrails in `AGENTS.md`: name the likely decay risk before adding behavior, avoid adding feature/business logic to files over 800 lines, extract helpers when adding >50 lines to files over 500 lines, split mixed-responsibility functions over 20 lines, prefer typed input objects over helpers with >4 parameters, and report large-file growth before completion.
- Current template port branch was renamed from `codex/claude-studios-port` to `codex-game-studios-port` to satisfy the no-`codex/` prefix rule.