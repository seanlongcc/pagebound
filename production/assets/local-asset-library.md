# Local Asset Library Inventory

> **Status**: Source library indexed, not imported
> **Last Updated**: 2026-05-10
> **Source Folder**: `C:\Users\seanl\Documents\Godot\assets`
> **WSL Path**: `/mnt/c/Users/seanl/Documents/Godot/assets`

## Import Policy

Do not bulk-copy this full folder into the Pagebound repo. It currently contains about **1.4 GB** and **88,427 files**. Import only curated subsets that match the chosen visual direction, then record source URL, creator, license, cost, allowed use, import date, and destination path.

Recommended repo destination for approved imports:

- `assets/art/source/` for original source files kept for traceability.
- `assets/art/sprites/` for runtime sprite sheets and sprites.
- `assets/art/textures/` for paper/material textures.
- `assets/ui/` for UI runtime assets.
- `assets/vfx/` for runtime VFX textures and flipbooks.
- `assets/fonts/` for approved game fonts.
- `assets/audio/` for approved audio.
- `production/assets/import-manifest.md` for per-asset provenance.

## Library Summary

| Folder | Size | Files | Notes |
|---|---:|---:|---|
| `Kenney Game Assets All-in-1 3.4.0` | 1.1 GB | 84,974 | Main broad source library: 2D, 3D, UI, icons, audio, and archived packs. Many packs include per-pack CC0 license files. |
| `HandDrawnIcons` | 137 MB | 1,782 | Cartoony/realistic icon sets. Style likely conflicts with new pixel/card direction unless used only for internal tooling. License not found in scan. |
| `brackeys_vfx_bundle` | 72 MB | 220 | VFX flipbooks, particles, predrawn sprite sheets. Local license says CC0 with credits to original creators. |
| `Paper Texture Backgrounds` | 47 MB | 13 | Paper JPG backgrounds. Useful for PageGround/material look. No license file found in folder. Must verify before import. |
| `Humble Gift - Paper UI System v1.1` | 7.4 MB | 1,416 | Paper UI sprites, sprite sheets, and Aseprite files. License is PDF; needs manual/legal review before import. |
| `Rainbow2000_Font_v1_04` | 1.1 MB | 18 | OTF/TTF/WOFF font family. Local license is CC0. |
| `friendlyscribbles` | 276 KB | 4 | Hand-drawn font. Local readme allows free use with attribution. Likely style mismatch for pixel direction. |

## File Type Summary

| Extension | Count | Import Notes |
|---|---:|---|
| `.png` | 57,822 | Primary image format; import curated subsets only. |
| `.fbx` | 5,063 | 3D source; avoid until 3D prop direction chosen. |
| `.obj` | 4,990 | 3D source; avoid until 3D prop direction chosen. |
| `.mtl` | 4,990 | OBJ material sidecars. |
| `.svg` | 4,846 | Useful for UI/icons if matching style; convert or import intentionally. |
| `.glb` | 4,724 | Godot-friendly 3D source; import only chosen props. |
| `.ogg` | 1,342 | Audio source pool; defer until audio system direction. |
| `.stl` | 1,264 | Not a likely runtime format for Pagebound. |
| `.dae` | 1,264 | 3D source; avoid unless needed. |
| `.ttf` | 41 | Font source pool. |
| `.jpg` | 19 | Mostly paper textures. |
| `.otf` | 18 | Font source pool. |
| `.tga` | 14 | Brackeys flipbooks. |

## Kenney Sub-Library

| Folder | Files | Pagebound Use |
|---|---:|---|
| `2D assets` | 39,096 | Best first pass for pixel/card prototypes and top-down visual tests. |
| `3D assets` | 27,406 | Useful later for diorama props if low-poly style is chosen. |
| `UI assets` | 6,580 | Useful for pixel UI prototypes; check style against paper UI. |
| `Icons` | 9,183 | Input prompts and readable game icons. Strong candidate for keyboard/gamepad prompts. |
| `Audio` | 1,319 | SFX/music source pool; defer until audio direction. |
| `Archive` | 1,308 | Older packs; avoid unless a specific archived style wins. |
| `Other` | 68 | Miscellaneous. |
| `Goodies` | 9 | Miscellaneous. |

Kenney packs that look especially relevant from folder names:

- `2D assets/Tiny Dungeon`
- `2D assets/Tiny Town`
- `2D assets/Micro Roguelike`
- `2D assets/Roguelike Base Pack`
- `2D assets/Roguelike Characters Pack`
- `2D assets/Roguelike Dungeon Pack`
- `2D assets/Roguelike Interior Pack`
- `2D assets/Topdown Shooter (Pixel)`
- `2D assets/RTS Medieval (Pixel)`
- `2D assets/Playing Cards Pack`
- `2D assets/Particle Pack`
- `2D assets/Smoke Particles`
- `UI assets/Fantasy UI Borders`
- `UI assets/UI Pack - Pixel Adventure`
- `Icons/Input Prompts`
- `Icons/Input Prompts Pixel 16x`
- `Audio/RPG Audio`
- `Audio/UI Audio`

## Pagebound Fit

Strong candidates:

- Kenney pixel/top-down/roguelike packs for early actor cards, pickups, icons, and chapter prototype markers.
- Paper Texture Backgrounds for PageGround/material exploration, after license verification.
- Humble Paper UI for menus or modal mockups, after license review.
- Brackeys VFX for temporary combat/ability VFX because local license says CC0.
- Kenney input prompts for keyboard/mouse, gamepad, and Steam Deck prompt prototypes.

Use cautiously:

- Hand-drawn icon/font packs because Pagebound is moving away from hand-drawn art.
- Kenney low-poly 3D kits unless the diorama prop style intentionally becomes low-poly.
- Large 3D model folders until import performance and art direction are settled.

Avoid for now:

- Full-library import.
- Mixed style imports in the same prototype scene.
- Any asset with missing or unclear license metadata.

## Immediate Next Asset Step

Pick one cohesive prototype lane:

1. **Kenney pixel lane**: `Tiny Dungeon` + `Tiny Town` + `Roguelike Characters Pack` + `UI Pack - Pixel Adventure`.
2. **Paper UI lane**: `Humble Gift - Paper UI System v1.1` + verified paper textures + simple Godot primitives.
3. **VFX lane**: Brackeys VFX + Kenney particles for temporary ability feedback.

After choosing a lane, create `production/assets/import-manifest.md`, copy only the selected files into repo paths, normalize names, then run Godot import and smoke validation.
