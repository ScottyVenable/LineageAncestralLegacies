# Unity Migration

This document outlines the high-level steps and considerations for migrating the Lineage project from GameMaker Studio 2 (GML) to Unity 2D (C#).

## 1. Project Planning & Setup
1.1 Analyze current GameMaker project structure and assets.
1.2 Define Unity folder structure (Assets/, Scripts/, Scenes/, Prefabs/, Resources/, Data/).
1.3 Establish version control (e.g., Git) in Unity workspace.
1.4 Determine target Unity version and required 2D packages (e.g., Cinemachine, Tilemap).

## 2. Asset Migration
2.1 Export sprites, animations, tilesets, and UI textures from GameMaker.
2.2 Import textures into Unity (convert GMS .sprite and texture packs to PNG sheets).
2.3 Configure Sprite Atlas, import settings (pixels per unit, pivot, compression).
2.4 Recreate animations in Unity Animation / Animator (Animation Clips, Controller).
2.5 Migrate audio assets (SFX, music) to Unity’s AudioClip and AudioMixer.

## 3. Scene & Prefab Setup
3.1 Rebuild rooms as Unity Scenes (e.g., World.unity).
3.2 Use Tilemap for tile-based levels; convert GameMaker rooms to Unity Tilemap grids.
3.3 Create Prefabs for recurring objects (pops, bushes, resources, UI panels).
3.4 Configure ordering, layers, and Z-depth for 2D sorting.

## 4. Gameplay Logic Conversion
4.1 Translate GML scripts to C#:
  - Map GameMaker objects (obj_pop) to MonoBehaviour scripts (e.g., PopController.cs).
  - Convert Create/Step events to Awake/Start and Update methods.
  - Rewrite global variables (global.GameData) as singleton managers (e.g., GameDataManager).
4.2 Implement input handling using Unity’s Input System or legacy Input API.
4.3 Migrate data loading (JSON) using Unity’s JsonUtility or Newtonsoft JSON.
4.4 Recreate debug console tools using in-game UI and debugging scripts.

## 5. Data & Name Generation
5.1 Place `name_data.json` in Unity’s Resources or StreamingAssets.
5.2 Load JSON at runtime into C# data classes (NameData, EntityData).
5.3 Rewrite name generation logic (`scr_generate_pop_name`) as a C# method (NameGenerator.cs).

## 6. UI & HUD
6.1 Rebuild UI using Unity UI (Canvas, Panels, Text, Buttons).
6.2 Migrate debug console panels and input fields.
6.3 Recreate status bars, inventory UI, and tooltips.

## 7. Testing & Iteration
7.1 Set up unit tests for core systems (data loading, name generation, inventory).
7.2 Playtest scenes and verify behavior matches GameMaker version.
7.3 Profile performance, optimize rendering and scripts.

## 8. Deployment & Builds
8.1 Configure Unity Build Settings for target platforms (Windows, HTML5, etc.).
8.2 Set up platform-specific settings (resolution, controls).
8.3 Run final QA and package builds.

---

**Notes:**
- Gradual migration: consider a hybrid approach (embedding Unity modules) or rewiring incremental features.
- Leverage Unity Asset Store packages for tilemap tools, UI frameworks, and input systems.
- Maintain documentation and ensure team training on C#, Unity Editor, and best practices.
