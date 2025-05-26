# Lineage: Ancestral Legacies

![Lineage: Ancestral Legacies - Placeholder Banner/Logo](https://placehold.co/800x200/2D3748/E2E8F0?text=Lineage:+Ancestral+Legacies)
*(Replace the placeholder image URL above with a cool banner or logo for your game when you have one!)*

## 📜 Overview

**Lineage: Ancestral Legacies** is a pop-based simulation game where you guide a group of early hominids through the trials and triumphs of survival, growth, and societal development. Nurture your "Pops," manage their complex lives from resource gathering to skill development, and shape the legacy of their lineage as they navigate the challenges and opportunities of an early world.

This repository contains the source code and development progress for the game, built with **GameMaker Studio 2 (version 2024.13.1.242)**.

## 🌟 Core Features

* **Dynamic Pop Characters:** Each "Pop" (hominid character) is unique, with:
    * Gender-specific modular names.
    * Randomized age and D&D-style ability scores.
    * Age-reflective traits, likes, and dislikes influencing behavior.
    * Developing skills in various areas like foraging, crafting, and construction.
    * **Needs System:** Pops have needs like hunger and thirst that influence their behavior. (More to be implemented: energy, social interaction).
    * **Pop State System:** Pops transition between states (e.g., Idle, Foraging, Resting) based on their needs and tasks.
* **Resource Gathering & Management:** Pops can be commanded to forage for resources like berries and stone. Future plans include more complex resource chains (wood, minerals, etc.).
* **Basic Crafting System:** Pops can craft items from recipes if they have the required ingredients.
* **Struct-Based Inventory System:** Efficient and flexible inventory management for each Pop.
* **Evolving UI:** A draggable generic UI panel system for displaying information, currently showcasing detailed "Pop Info" panels including stats, traits, and inventory.
* **Dynamic Foraging Efficiency:** A Pop's ability to gather resources is influenced by their stats (e.g., Wisdom, Dexterity) and traits (e.g., "Hardworking," "Lazy").
* **Item Definition System:** A robust system for defining game items, their properties, and their inventory sprites, with graceful fallback to a placeholder icon (`spr_placeholder_icon`) for art assets not yet created.

## 💻 Technology Stack

* **Game Engine:** GameMaker Studio 2
* **GMS2 Version:** 2024.13.1.242 (This is important due to specific engine quirks noted below)
* **Language:** GameMaker Language (GML)

## 🛠️ Current Status

The game is currently in active development. Core systems for Pop creation, basic behaviors (idle, wander, commanded, foraging), item definitions, and the foundational UI panel are in place. Recent focus has been on implementing core gameplay loops like needs management, pop states, and a basic crafting system.

**Key systems recently implemented or improved:**
* **Pop State System:** Pops now have defined states (Idle, Foraging, Resting) managed through `datafiles/pop_states.json` and loaded via `scr_load_external_data.gml`. Pop behavior in `obj_pop` is driven by these states.
* **Needs System:** Pops now have basic needs (hunger, thirst) initialized in `obj_pop` and updated by `scr_needs_update.gml`. Helper functions in `scr_data_helpers.gml` assist with accessing need data.
* **Basic Crafting System:** A foundational crafting system allows Pops to craft items based on recipes defined in `datafiles/recipes.json` (loaded by `scr_load_external_data.gml`). Crafting logic is handled by `scr_crafting_functions.gml`, with helper functions in `scr_data_helpers.gml`.
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
* **Expanded Pop Needs & Behaviors:** Implement systems for energy, social interaction, and more complex AI decision-making based on needs and states.
* **Skill Progression:** Allow Pops to gain experience and improve their skills over time.
* **Advanced Crafting & Construction:** Expand the crafting system with more recipes, tool requirements, and introduce systems for Pops to build structures.
* **UI for Crafting:** Develop a user interface for players to see available recipes and initiate crafting.
* **World Generation & Exploration:** Develop more dynamic environments for Pops to inhabit.
* **Tribal Dynamics:** Introduce concepts of leadership, family units, and inter-Pop relationships.
* **Events & Challenges:** Add dynamic events (e.g., weather, animal attacks, resource booms/busts) to challenge the player.
* **More UI Panels:** Develop UI for construction, crafting, research, etc.

## 📄 License

*(This section is for you to fill in based on your choice. Here are a few options:)*

**Option A (If you choose no license - Default Copyright):**
> Copyright (c) [Current Year] Scotty Venable. All Rights Reserved.
>
> This software is the proprietary property of Scotty Venable. You may view this code for educational purposes if the repository is public. However, you may not use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, nor permit persons to whom the Software is furnished to do so, without express written permission from Scotty Venable.

**Option B (If you choose MIT License - permissive open source):**
> This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

**Option C (If you choose another license):**
> This project is licensed under the [Your Chosen License Name] - see the [LICENSE.md](LICENSE.md) file for details.

*(Remember to create a `LICENSE.md` file in your repository if you choose Option B or C and paste the full license text there.)*

## 👨‍💻 Author / Contact

* **Scotty Venable**
    * scottyvenable@gmail.com

## 🙏 Acknowledgements (Optional)

---

This README aims to provide a clear and comprehensive overview of **Lineage: Ancestral Legacies**. Happy developing!
