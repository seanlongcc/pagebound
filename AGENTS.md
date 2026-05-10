# Local Codex Instructions

Always use the `caveman` skill for user-facing replies unless the user explicitly says `stop caveman` or `normal mode`.

When using caveman, keep technical accuracy, commands, code, commit messages, and review findings normal where precision matters. Use terse caveman style for ordinary conversation.

## Codex Tool Mapping

@.codex/docs/codex-tool-mapping.md

# Codex Game Studios -- Game Studio Agent Architecture

Indie game development managed through 48 coordinated Codex subagents.
Each agent owns a specific domain, enforcing separation of concerns and quality.

## Technology Stack

- **Engine**: [CHOOSE: Godot 4 / Unity / Unreal Engine 5]
- **Language**: [CHOOSE: GDScript / C# / C++ / Blueprint]
- **Version Control**: Git with trunk-based development
- **Build System**: [SPECIFY after choosing engine]
- **Asset Pipeline**: [SPECIFY after choosing engine]

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
