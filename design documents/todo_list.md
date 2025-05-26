# Project To-Do List: Lineages - Ancestral Legacies

This to-do list is based on our recent discussions and aims to help prioritize tasks and refine your development process.

## I. Core Data System Implementation (JSON & global.GameData)

- [x] Confirm the list of JSON files to load (items.json, resource_node_data.json, structure_data.json, entity_data.json, pop_name_data.json)
- [x] Implement the file loading loop that iterates through these filenames (`scr_load_external_data_all`)
- [x] Create initial default JSON data files for structures, entities, and pop names (`structure_data.json`, `entity_data.json`, `pop_name_data.json`)
- [x] Implement robust file handling (folder creation, default fallbacks, corrupted JSON handling)
- [x] Implement First Pass - Population logic to merge JSON into `global.GameData`
- [x] Implement Second Pass - Linking/Resolution logic for ID references
- [ ] Add `default_[category].json` files to the project as included files

## II. Script Organization & Refinement

- [x] Categorize root-level scripts:
  - [x] Move `scr_debug_log` to `Utilities`
  - [x] Create `Systems/Inventory` and move inventory scripts (`scr_inventory_functions`, `scr_inventory_struct_management`)
  - [x] Evaluate and relocate or deprecate `scr_item_definitions` (deprecated in favor of JSON system)
  - [x] Move JSON loading scripts (`scr_load_external_data`, `scr_load_text_file_lines`) to `Data/Loading`
  - [x] Move `scr_pop_resume_previous_or_idle` to `Pop/Behaviors`
  - [x] Relocate `TEMPLATE_SCRIPT` reference files to `ProjectTemplates`
- [x] Review and refine contents of `scr_constants`, `scr_database`, `scr_items`, `scr_resources`, `scr_traits` (code consolidated into JSON-driven helpers)
- [x] Address experimental `group1` folder (moved contents to `_Sandbox` or removed)

## III. Code Standards & Practices (Reinforcement)

- [x] Apply `TEMPLATE_SCRIPT.txt` structure to all new and existing GML scripts
- [x] Gradually refactor key scripts to match the template (started with major systems: data loader, gamedata init, pop behavior)
- [x] Maintain rigorous commenting (explained "what" and "why" consistently across code)
- [x] Enforce naming conventions across variables, scripts, and assets (converted legacy names to enums and template style)

## IV. Specific Feature Development/Refinement

- [x] Prototype Pop State System Refactor (Data-Driven)
  - [x] Define pop state definitions in JSON (e.g., `pop_states.json`)
  - [x] Modify `obj_pop` to read state behavior from `global.GameData`
  - [x] Test with Idle, Wandering, Commanded states (Tested with Idle, Foraging, Resting)
- [x] Implement initial Needs system for pops (Hunger, Thirst)
- [x] Begin Basic Crafting System Implementation
  - [x] Ensure `recipes.json` is loaded
  - [ ] Create UI for recipe selection
  - [x] Implement inventory check and crafting logic for example recipes

## V. Documentation & Project Management

- [x] Update design documents (`GDD.md`, `Unified GameData System.md`) to reflect implementation
- [ ] Update `Utilizing the Unified GameData System.md` to reflect implementation
- [x] Maintain versioning and formatting per `DOCUMENT_FORMATTING_GUIDELINES.md`
- [x] Keep `README.md` updated with current status and key features


## VI. Additional Tasks
- [ ] Refactor code such as scr_needs_update that is directed to just Pops to make them universal (since all entities will have needs).
