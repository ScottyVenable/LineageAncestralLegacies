# Lineage: Ancestral Legacies

## 📜 Overview

**Lineage: Ancestral Legacies** is a pop-based simulation game where you guide a group of early hominids through the trials and triumphs of survival, growth, and societal development. Nurture your "Pops," manage their complex lives from resource gathering to skill development, and shape the legacy of their lineage as they navigate the challenges and opportunities of an early world.

This repository contains the source code and development progress for the game, built with **GameMaker Studio 2 (version 2024.13.1.242)**.

## 🌟 Core Features

* **Dynamic Pop Characters:** Each "Pop" (hominid character) is unique, with:
    * Gender-specific modular names.
    * Randomized age and D&D-style ability scores.
    * Age-reflective traits, likes, and dislikes influencing behavior.
    * Developing skills in various areas like foraging, crafting, and construction.
    * Needs such as hunger, thirst, energy, and social interaction (more to be implemented).
* **Resource Gathering & Management:** Pops can be commanded to forage for resources like berries and stone. Future plans include more complex resource chains (wood, minerals, etc.).
* **Struct-Based Inventory System:** Efficient and flexible inventory management for each Pop.
* **Evolving UI:** A draggable generic UI panel system for displaying information, currently showcasing detailed "Pop Info" panels including stats, traits, and inventory.
* **Dynamic Foraging Efficiency:** A Pop's ability to gather resources is influenced by their stats (e.g., Wisdom, Dexterity) and traits (e.g., "Hardworking," "Lazy").
* **Item Definition System:** A robust system for defining game items, their properties, and their inventory sprites, with graceful fallback to a placeholder icon (`spr_placeholder_icon`) for art assets not yet created.

## 💻 Technology Stack

* **Game Engine:** GameMaker Studio 2
* **GMS2 Version:** 2024.13.1.242 (This is important due to specific engine quirks noted below)
* **Language:** GameMaker Language (GML)

## 🛠️ Current Status

The game is currently in active development. Core systems for Pop creation, basic behaviors (idle, wander, commanded, foraging), item definitions, and the foundational UI panel are in place. Recent focus has been on refining the "Pop Info" UI panel and establishing robust item/sprite definition workflows.

**Key systems recently implemented or improved:**
* Dynamic Pop Foraging Efficiency.
* Safe sprite assignment in item definitions (fallback to `spr_placeholder_icon`).
* Consolidated global enums (`PopState`, `ItemType`, etc.) in `scr_constants.gml`.
* Resolution of various initialization bugs related to UI panel dimensions and global item definitions.

## ⚙️ Getting Started / Prerequisites

To open and run this project:
1.  You will need **GameMaker Studio 2, version 2024.13.1.242** or a compatible later version (though later versions might behave differently with noted quirks).
2.  Clone this repository to your local machine.
3.  Open the `LineageAncestralLegacies.yyp` (or your project's .yyp file) in GameMaker Studio 2.

## ⚠️ Known GameMaker Version Quirks (v2024.13.1.242)

This specific version of GameMaker has presented some unique challenges:
* **Unrecognized Built-in Functions:** `array_random()`, `array_indexOf()`, and `camera_exists()` are not recognized and cause "variable not set" errors. Workarounds (manual helper functions, alternative checks) are implemented where these were needed.
* **Mouse Coordinates:** Issues have been observed with reliably accessing `mouse_x`/`mouse_y` (and `other.mouse_x`/`global.mouse_x`) in certain event contexts (e.g., `obj_controller`'s Global Right Pressed event). The current workaround involves caching `device_mouse_x(0)` and `device_mouse_y(0)` at the start of such events.
* **`variable_instance_remove()`:** Caused errors when used with temporary struct arguments in `obj_UIPanel_Generic`'s Create Event (related lines were commented out).

These quirks are important to keep in mind if troubleshooting or developing further in this GMS2 version.

## 🗺️ Roadmap / Future Goals (Examples - Customize these!)

While the foundation is being laid, here are some potential future directions:
* **Expanded Pop Needs & Behaviors:** Implement systems for hunger, thirst, sleep, social interaction, and more complex AI decision-making.
* **Skill Progression:** Allow Pops to gain experience and improve their skills over time.
* **Crafting & Construction:** Introduce systems for Pops to craft tools, clothing, and build structures.
* **World Generation & Exploration:** Develop more dynamic environments for Pops to inhabit.
* **Tribal Dynamics:** Introduce concepts of leadership, family units, and inter-Pop relationships.
* **Events & Challenges:** Add dynamic events (e.g., weather, animal attacks, resource booms/busts) to challenge the player.
* **More UI Panels:** Develop UI for construction, crafting, research, etc.

## 📄 License

> Copyright © 2025 Cadential Studios. All Rights Reserved.
>
> This software is the proprietary property of Scotty Venable. You may view this code for educational purposes if the repository is public. However, you may not use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, nor permit persons to whom the Software is furnished to do so, without express written permission from Scotty Venable.

## 👨‍💻 Author / Contact

* **Scotty Venable**
    * scottyvenable@gmail.com

