Project To-Do List: Lineages - Ancestral Legacies
This to-do list is based on our recent discussions, your project's current state (as understood from provided files and images), and general best practices. It aims to help prioritize tasks and refine your development process for Lineages: Ancestral Legacies.

I. Core Data System Implementation (JSON & global.GameData)
This is a foundational system and should be a high priority to get right, as many other systems will depend on it.

Task: Finalize and Implement scr_database.gml for Multi-File JSON Loading.

Recommendation/How-to:

Confirm the list of JSON files to load (e.g., items.json, entities.json, recipes.json, skills.json, traits.json, loot_tables.json, etc.) as per the Idea Document v1.3 [cite: game_data_json_idea_doc].

Implement the file loading loop that iterates through these filenames.

Crucially, implement the robust file handling:

Check for the data subfolder in working_directory; create it if missing.

For each JSON file:

Check if the user's version exists (e.g., working_directory + "/data/items.json").

If missing: Copy the corresponding default file (e.g., default_items.json from "Included Files") to the user's data folder. Then load this newly copied file.

If user's file exists: Attempt to load and parse it using try...catch.

If parsing fails (corrupted): Log the error. Load the corresponding internal default JSON file (from "Included Files") directly into memory for the current session without overwriting the user's corrupted file.

Ensure json_parse() is used safely.

Implement the "First Pass - Population" logic to merge data from each loaded JSON into the correct section of global.GameData. Pay attention to mapping string keys from JSON to GML enum keys where necessary (e.g., for Recipes, Skills, Traits).

Implement the "Second Pass - Linking/Resolution" logic to convert all string ID references (e.g., item_id_ref in recipes) into direct GML struct references after all files have been loaded and populated.

Reference: "Idea Doc: JSON-Driven Game Data System for Lineages (User Folder & Fallbacks)" [cite: game_data_json_idea_doc].

Task: Create Initial Default JSON Data Files.

Recommendation/How-to:

For each category (items, entities, etc.), create a default_[category].json file (e.g., default_items.json).

Populate these with a few representative examples of your data structures (like the items.json example we discussed [cite: example_items_json]).

Ensure these default files are syntactically correct JSON and match the structure your GML script expects.

Add these default JSON files to your GameMaker project as "Included Files."

Tip: Start small. You don't need all game data defined yet, just enough to test the loading and linking system thoroughly for each category.

Task: Define and Implement Helper Functions for Data System.

Recommendation/How-to:

get_enum_value_from_string(enum_asset_name_string, enum_member_name_string): To map JSON string keys to GML enum values.

find_item_profile_by_id(item_id_str), find_skill_profile_by_id(skill_id_str), etc.: These are crucial for the "Second Pass - Linking" phase. They will search the populated global.GameData for entries matching the string IDs.

Placement: These could go into a "Data/Helpers" script folder or be part_of scr_database.gml if they are only used there.

Task: Thoroughly Test the Data Loading and Fallback System.

Recommendation/How-to:

Test scenario: data folder missing (should be created, defaults copied).

Test scenario: Specific user JSON file missing (default should be copied).

Test scenario: User JSON file exists but is corrupted (e.g., syntax error). (Game should load internal default for that category for the session, user file remains untouched).

Test scenario: User JSON file is valid JSON but contains an incorrect item_id_ref. (Linking phase should log an error, but not crash).

Verify that global.GameData is populated and linked correctly in all scenarios using the debugger and show_debug_message().

II. Script Organization & Refinement
Based on the script folder images [cite: uploaded:image_95690b.png-cd470923-5493-4d1a-9430-9eff85a449c6, uploaded:image_9568b3.png-73a1bbc4-0cb5-4a04-8782-72ba75407d0c], let's refine the structure.

Task: Categorize Root-Level Scripts.

Recommendation/How-to:

scr_debug_log: Move to "Utilities".

scr_inventory_functions, str_inventory_struct_management (rename to scr_inventory_struct_management): Create a new top-level folder "Systems" and a subfolder "Inventory" (i.e., "Systems/Inventory"). Place these here.

scr_item_definitions: If this is for GML-defined items, it will likely be deprecated by the JSON system. If it's a helper for processing loaded item data, it could go into "Data/Helpers" or "Systems/Inventory" if specific to items in inventories. Evaluate its new role.

scr_load_external_data, scr_load_text_file_lines: These are part of your JSON loading. They could be integrated into scr_database.gml or be helpers in a "Data/Loading" subfolder.

scr_pop_resume_previous_or_idle: Move to "Pop/Behaviors".

TEMPLATE_SCRIPT: Keep it in its current location (scripts/TEMPLATE_SCRIPT/TEMPLATE_SCRIPT.txt) [cite: scottyvenable/lineageancestrallegacies/LineageAncestralLegacies-e4cf18359f7b9c015312162be17ad75886aacfa9/scripts/TEMPLATE_SCRIPT/TEMPLATE_SCRIPT.txt] as a clear reference, or move the .txt to a "ProjectTemplates" folder if you prefer to keep the scripts folder purely for GML.

Goal: Minimize scripts directly under the root "Scripts" folder.

Task: Review and Refine "Data" Folder Contents.

Recommendation/How-to:

scr_constants: Stays. Essential.

scr_database: Stays. Central data loader.

scr_items, scr_resources, scr_traits: As with scr_item_definitions, determine their role post-JSON migration. If they become GML-based definitions, they are replaced. If they are helper scripts for using the JSON-loaded data (e.g., function get_item_tag_value(item_profile_struct, tag_name)), they could be in "Data/Helpers" or moved to system-specific folders (e.g., item helpers to "Systems/Inventory").

Task: Address "group1" Folder.

Recommendation/How-to: Identify the purpose of scripts within "group1" and move them to appropriate existing or new categorized folders. If they are experimental, create an "Experimental" or "_Sandbox" folder.

III. Code Standards & Practices (Reinforcement)
You have excellent standards defined. This is about consistent application.

Task: Apply TEMPLATE_SCRIPT.txt to All New and Existing GML Scripts.

Recommendation/How-to:

For all new GML scripts, strictly follow the structure in TEMPLATE_SCRIPT.txt [cite: scottyvenable/lineageancestrallegacies/LineageAncestralLegacies-e4cf18359f7b9c015312162be17ad75886aacfa9/scripts/TEMPLATE_SCRIPT/TEMPLATE_SCRIPT.txt] and DOCUMENT_FORMATTING_GUIDELINES.md [cite: scottyvenable/lineageancestrallegacies/LineageAncestralLegacies-e4cf18359f7b9c015312162be17ad75886aacfa9/DOCUMENT_FORMATTING_GUIDELINES.md].

Gradually refactor existing key scripts to match this template for consistency. Start with the most complex or frequently edited ones.

Pay close attention to the detailed header block, function encapsulation, and the numbered #region sections.

Task: Maintain Rigorous Commenting.

Recommendation/How-to: Continue the practice of explaining the "what" and "why" in comments, as per your copilot-instructions.md [cite: scottyvenable/lineageancestrallegacies/LineageAncestralLegacies-e4cf18359f7b9c015312162be17ad75886aacfa9/.github/copilot-instructions.md] and DOCUMENT_FORMATTING_GUIDELINES.md [cite: scottyvenable/lineageancestrallegacies/LineageAncestralLegacies-e4cf18359f7b9c015312162be17ad75886aacfa9/DOCUMENT_FORMATTING_GUIDELINES.md]. This is especially important for a learning project and for future maintainability.

Task: Enforce Naming Conventions.

Recommendation/How-to: Double-check that all new and refactored variables, scripts, objects, and constants adhere to the naming conventions outlined in your DOCUMENT_FORMATTING_GUIDELINES.md [cite: scottyvenable/lineageancestrallegacies/LineageAncestralLegacies-e4cf18359f7b9c015312162be17ad75886aacfa9/DOCUMENT_FORMATTING_GUIDELINES.md].

IV. Specific Feature Development/Refinement (Examples)
Based on your GDD [cite: scottyvenable/lineageancestrallegacies/LineageAncestralLegacies-e4cf18359f7b9c015312162be17ad75886aacfa9/design documents/GDD.md] and other design documents.

Task: Prototype Pop State System Refactor (Data-Driven).

Recommendation/How-to:

Refer to your "Pop State System Refactor" idea in coding_ideas.md [cite: scottyvenable/lineageancestrallegacies/LineageAncestralLegacies-e4cf18359f7b9c015312162be17ad75886aacfa9/design documents/Idea Documents/coding_ideas.md].

Define a section in one of your JSON files (e.g., entities.json or a new pop_states.json) to store state definitions (on_enter, on_execute, on_exit scripts, valid transitions, etc.).

Modify obj_pop to read its current state's behavior from global.GameData and execute the appropriate scripts.

Start with 2-3 simple states (e.g., Idle, Wandering, Commanded) to prove the concept.

Task: Implement Initial "Needs System" for Pops.

Recommendation/How-to:

Define basic needs (e.g., Hunger, Thirst) in obj_pop.

Create logic for these needs to decrease over time.

Implement behavior in the Pop FSM for pops to autonomously seek and consume resources from their inventory or nearby sources (defined in global.GameData) when a need drops below a threshold.

Reference Section 3.1 and 3.2 of your GDD [cite: scottyvenable/lineageancestrallegacies/LineageAncestralLegacies-e4cf18359f7b9c015312162be17ad75886aacfa9/design documents/GDD.md].

Task: Begin Basic Crafting System Implementation.

Recommendation/How-to:

Ensure recipes.json (and its default_recipes.json) is being loaded.

Create a simple UI for a pop to select a known recipe (from global.GameData.Recipes).

Implement logic to check pop's inventory for ingredients (defined in the recipe profile).

Implement logic to consume ingredients and add the crafted item (defined in recipe_profile.produces_item_profile_path) to the pop's inventory.

Start with 1-2 very simple recipes (e.g., Stone Axe from Flint and Stick).

Reference Section 3.5 of your GDD [cite: scottyvenable/lineageancestrallegacies/LineageAncestralLegacies-e4cf18359f7b9c015312162be17ad75886aacfa9/design documents/GDD.md].

V. Documentation & Project Management
Task: Keep Design Documents Updated.

Recommendation/How-to: As you implement systems (especially the global.GameData structure and JSON formats), update your GDD [cite: scottyvenable/lineageancestrallegacies/LineageAncestralLegacies-e4cf18359f7b9c015312162be17ad75886aacfa9/design documents/GDD.md], "Unified GameData System.md" [cite: scottyvenable/lineageancestrallegacies/LineageAncestralLegacies-e4cf18359f7b9c015312162be17ad75886aacfa9/design documents/Idea Documents/Unified GameData System.md], and "Utilizing the Unified GameData System.md" [cite: scottyvenable/lineageancestrallegacies/LineageAncestralLegacies-e4cf18359f7b9c015312162be17ad75886aacfa9/design documents/Idea Documents/Utilizing the Unified GameData System.md] to reflect the actual implementation. This is crucial for maintaining clarity.

Ensure versioning on these documents follows your DOCUMENT_FORMATTING_GUIDELINES.md [cite: scottyvenable/lineageancestrallegacies/LineageAncestralLegacies-e4cf18359f7b9c015312162be17ad75886aacfa9/DOCUMENT_FORMATTING_GUIDELINES.md].

Task: Maintain README.md.

Recommendation/How-to: Periodically update your README.md [cite: scottyvenable/lineageancestrallegacies/LineageAncestralLegacies-e4cf18359f7b9c015312162be17ad75886aacfa9/README.md] with the current status, key features implemented, and any new known GMS2 quirks.

This list should give you a good roadmap for the next phases of development, Scotty! Remember to break these down into smaller, manageable chunks. You're building something really cool and complex, and your detailed planning and documentation efforts are already paying off. Keep up the fantastic work!