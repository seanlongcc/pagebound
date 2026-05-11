# Codex Tool Mapping

Codex Game Studios uses Codex-native tool names in skill metadata and docs.

| Workflow need | Codex tool or pattern | Notes |
|---|---|---|
| Read files, list files, grep text | `exec_command` with `sed`, `rg --files`, `rg` | Prefer `rg` over slower search commands. |
| Write or edit files | `apply_patch` | Use for manual edits; bulk generated rewrites may use formatters or scripts. |
| Run shell commands | `exec_command` | Use safe, scoped commands from the repo root. |
| Spawn a specialist agent | `spawn_agent` | Use only when user explicitly requests delegation or parallel agent work. |
| Track multi-step work | `update_plan` | Keep one active step at a time. |
| Ask structured questions | `request_user_input` when available, otherwise ask directly | Keep questions short and limited. |
| Web search or fetch | `web.run` | Use official/current sources for unstable technical facts. |

When a migrated skill says to use a legacy workflow primitive, follow this mapping and the active Codex developer instructions.
