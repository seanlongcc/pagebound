# Local Codex Instructions

Always use the `caveman` skill for user-facing replies unless the user explicitly says `stop caveman` or `normal mode`.

When using caveman, keep technical accuracy, commands, code, commit messages, and review findings normal where precision matters. Use terse caveman style for ordinary conversation.

## Codex Tool Mapping

@.codex/docs/codex-tool-mapping.md

## MCP Servers And Local Tools

Use MCP/tool servers according to the task. Prefer official or local project sources for current facts.

- **Godot AI MCP**: Use for live editor work when Godot is open. Endpoint: `http://127.0.0.1:8000/mcp`. It can inspect scenes, list nodes, create/delete nodes, set properties, attach scripts, connect signals, update project settings, run the project/tests, inspect logs, and capture editor/game screenshots.
- **Serena MCP**: Use for project memory and semantic/code navigation when useful. Serena has limited GDScript language support in this project, so prefer it for memories and targeted searches; use `rg` and direct file reads for GDScript implementation details.
- **Browser Use / Playwright**: Use for local browser verification when a task involves a browser target. This Godot project usually needs Godot/editor verification instead.
- **Context7 MCP**: Use for current library/framework documentation when working with SDKs, APIs, CLIs, or framework-specific setup.
- **GitHub MCP**: Use for repository, issue, and PR context when GitHub data is needed.
- **Supabase MCP**: Use only for Supabase database/auth/storage/edge-function work.
- **Vercel MCP**: Use only for Vercel project, deployment, logs, env, domain, or platform work.
- **Resend MCP**: Use only for email delivery/template/domain tasks.
- **shadcn MCP**: Use for shadcn/ui component and registry workflows.

## Skills

Use skills when relevant:

- `superpowers:brainstorming` before creative feature/design work.
- `superpowers:systematic-debugging` before fixing bugs or unexpected behavior.
- `superpowers:test-driven-development` for feature or bugfix implementation where tests are practical.
- `superpowers:verification-before-completion` before claiming work is complete.
- `superpowers:requesting-code-review` for substantial completed changes.
- `brooks-lint` for code quality, architecture health, tech debt, maintainability, and test quality review.
- `caveman` for user-facing replies unless the user explicitly says `stop caveman` or `normal mode`.

## Beads Issue Tracking

This project uses `bd` (beads) for issue tracking. Run `bd prime` for current workflow context. Run `bd hooks install` only when hook-based workflow injection is wanted.

Default to creating or claiming a bead before changing code, docs, configuration, tests, schema, workflows, or deployment setup unless the user explicitly asks not to track the task. Create beads for bug fixes, feature work, refactors, investigations, verification tasks, and docs/process changes that future agents should remember. If a request is more than a tiny one-shot answer or command, make a bead. When unsure, create the bead.

Do not create duplicate beads. Search existing open, in-progress, and recently closed issues first when the task sounds similar. For large or multi-part work, create a parent epic or feature bead plus child task/bug beads with dependencies instead of one oversized issue. When substantial follow-up work is discovered but not handled immediately, create a new bead. If it belongs to the current work, add a note or dependency instead of leaving it only in chat. At completion, close completed beads with a reason and leave remaining follow-up as open beads.

Quick reference:

- `bd ready` - Find unblocked work.
- `bd create "Title" --type task --priority 2` - Create an issue.
- `bd show <id>` - Show issue details.
- `bd update <id> --claim` - Claim work.
- `bd close <id> --reason "Completed"` - Complete work.
- `bd dolt push` - Push beads to the configured remote.

## Git And Completion Workflow

- Use Conventional Commits for commit messages, for example `feat: add feed timer` or `fix: prevent media persistence`.
- Use Conventional Commit-style branch names with a slash after the type prefix, for example `feat/feed-timer`, `fix/media-persistence`, `chore/update-agent-rules`, or `docs/workflow-guide`.
- Do not create branches with the `codex/` prefix. Use descriptive Conventional Commit-style feature branches without that prefix.
- Before completion, run `git status --short --branch`.
- Summarize changed files and any checks that could not be run.
- If durable project facts changed, update the relevant Serena memories before finishing. Prefer assigning this to a background Serena memory refresh subagent while implementation or verification continues, then review the memory changes before completion.

## Brooks-Lint Development Guardrails

Use these rules to prevent large-file decay and refactors. They target Brooks-Lint risks: cognitive overload, change propagation, knowledge duplication, accidental complexity, dependency disorder, and domain model distortion.

The 800-line number is not a Brooks-Lint or book rule. It is a local repo guardrail derived from Brooks-Lint's cognitive-overload risk. Brooks-Lint's concrete signals are smaller: mixed-abstraction functions over 20 lines, parameter lists over 4 parameters, boolean expressions with 3 or more combined conditions, nesting deeper than 3, fan-out over 5 imports, and changes that ripple across more than 3 unrelated files.

Before adding behavior:

- Name the Brooks-Lint risk most likely to grow if the behavior is added inline.
- Choose the smallest existing module that owns the behavior, or create a focused module before adding feature logic.
- Keep Godot scripts, scenes, and UI controllers responsible for state ownership, effects, side effects, and wiring. Move validation, state transitions, serialization, payload building, placement, timer math, drag math, and runtime orchestration into focused helpers/resources/services.
- When React/TypeScript surfaces exist, keep React components responsible for state ownership, effects, side effects, and UI wiring. Move validation, state transitions, serialization, payload building, placement, timer math, drag math, and runtime orchestration into focused helpers.
- If a change would add more than 50 lines to a file already over 500 lines, create or extend a helper module in the same branch.
- If a file is over 800 lines, add no new feature/business logic there unless the change is only wiring existing helpers. Extract first.
- If a function grows past 20 lines while mixing UI, state transitions, persistence, and runtime work, split it before continuing.
- If a helper needs more than 4 parameters, prefer a typed input object with domain names.
- If one change touches more than 3 unrelated modules, stop and write/update the implementation plan so the boundaries are explicit.
- Avoid speculative abstractions. Extract around current repeated decisions or current complexity, not imagined future providers.
- Treat large test files like large production files: if a test file is over 800 lines, add new scenarios to a focused sibling test file or colocated helper test unless the scenario is truly broad integration coverage.
- Before completion, state whether any large file grew, why, and what remains to extract.

# Codex Game Studios -- Game Studio Agent Architecture

Indie game development managed through 48 coordinated Codex subagents.
Each agent owns a specific domain, enforcing separation of concerns and quality.

## Technology Stack

- **Engine**: Godot 4.6.2
- **Language**: GDScript
- **Version Control**: Git with trunk-based development
- **Build System**: SCons (engine), Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource pipeline

> **Note**: Engine-specialist agents exist for Godot, Unity, and Unreal with
> dedicated sub-specialists. Use the set matching your engine.

## Project Structure

@.codex/docs/directory-structure.md

## Engine Version Reference

@docs/engine-reference/godot/VERSION.md

## Technical Preferences

@.codex/docs/technical-preferences.md

## Coordination Rules

@.codex/docs/coordination-rules.md

## Collaboration Protocol

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Agents MUST ask "May I write this to [filepath]?" before using file-editing tools
- Agents MUST show drafts or summaries before requesting approval
- Multi-file changes require explicit approval for the full changeset
- No commits without user instruction

See `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` for full protocol and examples.

> **First session?** If the project has no engine configured and no game concept,
> run `/start` to begin the guided onboarding flow.

## Coding Standards

@.codex/docs/coding-standards.md

## Context Management

@.codex/docs/context-management.md
