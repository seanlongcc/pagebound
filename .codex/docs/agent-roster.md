# Agent Roster

The following agents are available. Each has a dedicated definition file in
`.codex/agents/`. Use the agent best suited to the task at hand. When a task
spans multiple domains, the coordinating agent (usually `producer` or the
domain lead) should delegate to specialists.

## Tier 1 -- Leadership Agents (GPT-5.5)
| Agent | Domain | When to Use |
|-------|--------|-------------|
| `creative-director` | High-level vision | Major creative decisions, pillar conflicts, tone/direction |
| `technical-director` | Technical vision | Architecture decisions, tech stack choices, performance strategy |
| `producer` | Production management | Sprint planning, milestone tracking, risk management, coordination |

## Tier 2 -- Department Lead Agents (GPT-5.3 Codex)
| Agent | Domain | When to Use |
|-------|--------|-------------|
| `game-designer` | Game design | Mechanics, systems, progression, economy, balancing |
| `lead-programmer` | Code architecture | System design, code review, API design, refactoring |
| `art-director` | Visual direction | Style guides, art bible, asset standards, UI/UX direction |
| `audio-director` | Audio direction | Music direction, sound palette, audio implementation strategy |
| `narrative-director` | Story and writing | Story arcs, world-building, character design, dialogue strategy |
| `qa-lead` | Quality assurance | Test strategy, bug triage, release readiness, regression planning |
| `release-manager` | Release pipeline | Build management, versioning, changelogs, deployment, rollbacks |
| `localization-lead` | Internationalization | String externalization, translation pipeline, locale testing |

## Tier 3 -- Specialist Agents (GPT-5.3 Codex or GPT-5.4 Mini)
| Agent | Domain | Model | When to Use |
|-------|--------|-------|-------------|
| `systems-designer` | Systems design | GPT-5.3 Codex | Specific mechanic implementation, formula design, loops |
| `level-designer` | Level design | GPT-5.3 Codex | Level layouts, pacing, encounter design, flow |
| `economy-designer` | Economy/balance | GPT-5.3 Codex | Resource economies, loot tables, progression curves |
| `gameplay-programmer` | Gameplay code | GPT-5.3 Codex | Feature implementation, gameplay systems code |
| `engine-programmer` | Engine systems | GPT-5.3 Codex | Core engine, rendering, physics, memory management |
| `ai-programmer` | AI systems | GPT-5.3 Codex | Behavior trees, pathfinding, NPC logic, state machines |
| `network-programmer` | Networking | GPT-5.3 Codex | Netcode, replication, lag compensation, matchmaking |
| `tools-programmer` | Dev tools | GPT-5.3 Codex | Editor extensions, pipeline tools, debug utilities |
| `ui-programmer` | UI implementation | GPT-5.3 Codex | UI framework, screens, widgets, data binding |
| `technical-artist` | Tech art | GPT-5.3 Codex | Shaders, VFX, optimization, art pipeline tools |
| `sound-designer` | Sound design | GPT-5.4 Mini | SFX design docs, audio event lists, mixing notes |
| `writer` | Dialogue/lore | GPT-5.3 Codex | Dialogue writing, lore entries, item descriptions |
| `world-builder` | World/lore design | GPT-5.3 Codex | World rules, faction design, history, geography |
| `qa-tester` | Test execution | GPT-5.4 Mini | Writing test cases, bug reports, test checklists |
| `performance-analyst` | Performance | GPT-5.3 Codex | Profiling, optimization recs, memory analysis |
| `devops-engineer` | Build/deploy | GPT-5.4 Mini | CI/CD, build scripts, version control workflow |
| `analytics-engineer` | Telemetry | GPT-5.3 Codex | Event tracking, dashboards, A/B test design |
| `ux-designer` | UX flows | GPT-5.3 Codex | User flows, wireframes, accessibility, input handling |
| `prototyper` | Rapid prototyping | GPT-5.3 Codex | Throwaway prototypes, mechanic testing, feasibility validation |
| `security-engineer` | Security | GPT-5.3 Codex | Anti-cheat, exploit prevention, save encryption, network security |
| `accessibility-specialist` | Accessibility | GPT-5.4 Mini | WCAG compliance, colorblind modes, remapping, text scaling |
| `live-ops-designer` | Live operations | GPT-5.3 Codex | Seasons, events, battle passes, retention, live economy |
| `community-manager` | Community | GPT-5.4 Mini | Patch notes, player feedback, crisis comms, community health |

## Engine-Specific Agents (use the set matching your engine)

### Engine Leads

| Agent | Engine | Model | When to Use |
| ---- | ---- | ---- | ---- |
| `unreal-specialist` | Unreal Engine 5 | GPT-5.3 Codex | Blueprint vs C++, GAS overview, UE subsystems, Unreal optimization |
| `unity-specialist` | Unity | GPT-5.3 Codex | MonoBehaviour vs DOTS, Addressables, URP/HDRP, Unity optimization |
| `godot-specialist` | Godot 4 | GPT-5.3 Codex | GDScript patterns, node/scene architecture, signals, Godot optimization |

### Unreal Engine Sub-Specialists

| Agent | Subsystem | Model | When to Use |
| ---- | ---- | ---- | ---- |
| `ue-gas-specialist` | Gameplay Ability System | GPT-5.3 Codex | Abilities, gameplay effects, attribute sets, tags, prediction |
| `ue-blueprint-specialist` | Blueprint Architecture | GPT-5.3 Codex | BP/C++ boundary, graph standards, naming, BP optimization |
| `ue-replication-specialist` | Networking/Replication | GPT-5.3 Codex | Property replication, RPCs, prediction, relevancy, bandwidth |
| `ue-umg-specialist` | UMG/CommonUI | GPT-5.3 Codex | Widget hierarchy, data binding, CommonUI input, UI performance |

### Unity Sub-Specialists

| Agent | Subsystem | Model | When to Use |
| ---- | ---- | ---- | ---- |
| `unity-dots-specialist` | DOTS/ECS | GPT-5.3 Codex | Entity Component System, Jobs, Burst compiler, hybrid renderer |
| `unity-shader-specialist` | Shaders/VFX | GPT-5.3 Codex | Shader Graph, VFX Graph, URP/HDRP customization, post-processing |
| `unity-addressables-specialist` | Asset Management | GPT-5.3 Codex | Addressable groups, async loading, memory, content delivery |
| `unity-ui-specialist` | UI Toolkit/UGUI | GPT-5.3 Codex | UI Toolkit, UXML/USS, UGUI Canvas, data binding, cross-platform input |

### Godot Sub-Specialists

| Agent | Subsystem | Model | When to Use |
| ---- | ---- | ---- | ---- |
| `godot-gdscript-specialist` | GDScript | GPT-5.3 Codex | Static typing, design patterns, signals, coroutines, GDScript performance |
| `godot-shader-specialist` | Shaders/Rendering | GPT-5.3 Codex | Godot shading language, visual shaders, particles, post-processing |
| `godot-gdextension-specialist` | GDExtension | GPT-5.3 Codex | C++/Rust bindings, native performance, custom nodes, build systems |
