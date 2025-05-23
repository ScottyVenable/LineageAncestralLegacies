# Document Formatting Guidelines

This document outlines the formatting rules for all project documents, including the Game Design Document (GDD), to ensure consistency and clarity.

## General Formatting
- Use Markdown for all text-based documents.
- Use clear and concise language.
- Employ headings, subheadings, bullet points, and numbered lists to structure information logically.
- Ensure code blocks are properly formatted for readability.

## Scope
These guidelines apply to all project-related documents, including but not limited to:
- Game Design Documents (GDDs)
- Code files (GML, Python, etc.)
- Notes and research documents
- Commit messages and version control practices
- Issue tracking and project management entries

## Versioning
All key project documents, especially the GDD, must include a version number and the date of the last update.
This also applies to significant iterations of planning documents or notes if they supersede previous versions. For code, versioning is primarily handled by Git (see Section 5).

### Version Number Format
The version number should follow a date-based format: `vYYYY.M.D.iteration`

Where:
- `YYYY`: Four-digit year (e.g., 2025)
- `M`: Month (e.g., 1, 5, 12)
- `D`: Day (e.g., 1, 23)
- `iteration`: A number representing the update sequence for that specific day, starting from 1. If it's the first update of the day, it's `.1`. If it's the second update on the same day, it's `.2`, and so on.

**Example:**
- First update on May 23, 2025: `v2025.5.23.1`
- Second update on May 23, 2025: `v2025.5.23.2`
- First update on May 24, 2025: `v2025.5.24.1`

### Placement
The version number and last updated date should be clearly visible at the beginning of the document for text-based design and planning documents.

For `GDD.md`:
```
## **Lineage: Ancestral Legacies - Design Document**
**Version:** vYYYY.M.D.iteration
**Last Updated:** YYYY-MM-DD
```

## File Naming
- Use `UPPER_SNAKE_CASE` for primary design documents and configuration files (e.g., `DOCUMENT_FORMATTING_GUIDELINES.md`, `PROJECT_CONFIG.json`).
- For GameMaker Language (GML) scripts, follow GameMaker conventions:
    - `scr_` prefix for scripts (e.g., `scr_player_movement.gml`)
    - `obj_` prefix for objects (e.g., `obj_enemy.gml`)
    - `spr_` prefix for sprites (e.g., `spr_character_idle.png`)
    - `rm_` prefix for rooms (e.g., `rm_level_one.yy`)
    - `snd_` prefix for sounds (e.g., `snd_jump_effect.wav`)
    - `fnt_` prefix for fonts (e.g., `fnt_main_menu.ttf`)
- For notes and less formal documents, `kebab-case` or descriptive `Title Case With Spaces.md` can be used for readability (e.g., `initial-brainstorming-notes.md` or `Biome Research Notes.md`).
- Be descriptive with filenames to clearly indicate the content or purpose.

## Headings
- Use `#` for H1 (main title), `##` for H2, `###` for H3, and so on.
- Ensure a logical hierarchy of headings.

By adhering to these guidelines, we can maintain a well-organized and easy-to-navigate set of project documents.

---

## 4. Code Formatting (GML & General)

These guidelines are intended to make the codebase accessible, educational, and maintainable, especially for those learning game development. Refer to `COPILOT_INSTRUCTIONS.txt` for AI-assisted code generation principles.

### 4.1. General Principles
- **Clarity Over Brevity:** Write code that is easy to understand, even if it means being slightly more verbose.
- **Consistency:** Adhere to the established style and conventions throughout the project.
- **Modularity:** Break down complex logic into smaller, manageable functions or scripts.

### 4.2. Comments
- **Always Add Comments:** As outlined in `COPILOT_INSTRUCTIONS.txt`, every piece of generated or edited code should be commented.
    - Explain *what* the code does.
    - Explain *why* a particular approach was taken, especially if it's non-obvious.
    - Use beginner-friendly language.
- **Block Comments:** For scripts or complex functions, include a block comment at the beginning explaining its purpose, parameters (if any), and what it returns (if anything).
    ```gml
    // scr_calculate_damage(attacker_stats, defender_stats, weapon_bonus)
    // This script calculates the final damage dealt in a combat interaction.
    // attacker_stats: (Struct) Contains stats of the attacker (e.g., strength, agility).
    // defender_stats: (Struct) Contains stats of the defender (e.g., defense, constitution).
    // weapon_bonus: (Real) Additional damage from the equipped weapon.
    // Returns: (Real) The calculated damage value.
    // Reasoning: Uses a formula that considers attack vs. defense, with a random factor for variability.
    ```
- **Inline Comments:** Use for clarifying individual lines or small blocks of code.
    ```gml
    x += 5; // Move the instance 5 pixels to the right
    ```

### 4.3. Naming Conventions (GML)
- **Scripts:** `scr_verb_noun` or `scr_noun_verb` (e.g., `scr_player_jump`, `scr_inventory_add_item`).
- **Objects:** `obj_noun` or `obj_category_noun` (e.g., `obj_player`, `obj_enemy_goblin`, `obj_ui_button`).
- **Variables:**
    - Instance variables: `snake_case` (e.g., `move_speed`, `current_health`).
    - Local variables: `_snake_case` (prefix with underscore) (e.g., `_temp_damage`, `_can_proceed`).
    - Global variables: `global.snake_case` (e.g., `global.game_paused`, `global.score`).
    - Macros/Constants: `ALL_CAPS_SNAKE_CASE` (e.g., `MAX_PLAYERS`, `DEFAULT_VOLUME`).
- **Structs & Constructors:** `PascalCase` for constructor function names (e.g., `function InventoryItem(_name, _type)`).
- **Cached Locals (within functions):** `_snake_case` often used for local variables that cache frequently accessed global values or script functions (e.g., `var _room_speed = room_speed;`, `var _cached_script = scr_another_function;`).

### 4.4. Structure & Readability
- **Indentation:** Use consistent indentation (e.g., 4 spaces or tabs, as configured in GameMaker).
- **Whitespace:** Use blank lines to separate logical blocks of code within a script or event.
- **Line Length:** Avoid excessively long lines of code. Break them down if necessary.
- **GameMaker Script Template:** For new GML scripts, **strictly follow the structure and conventions outlined in `TEMPLATE_SCRIPT/TEMPLATE_SCRIPT.gml`**. This template provides a standardized framework for all scripts, enhancing readability and maintainability. Key aspects of this template include:
    - **Comprehensive Header Block:** All scripts must begin with a detailed comment block formatted as seen in the template:
        ```gml
        /// script_file_name.gml
        ///
        /// Purpose:
        ///   [Detailed explanation of what the script does, its role, and for which entities/systems it's intended.]
        ///
        /// Metadata:
        ///   Summary:       [Concise one-line summary of the script's function.]
        ///   Usage:         [Where and how this script is typically called (e.g., "obj_pop Step Event", "Called by scr_combat_manager").]
        ///   Parameters:    [param_name : type — Detailed purpose of the parameter.]
        ///                  [another_param : type — Detailed purpose.]
        ///                  (Use "none" if no parameters)
        ///   Returns:       [Return type — Detailed explanation of what the script returns, or "void" if nothing.]
        ///   Tags:          [[tag1][tag2][category] (e.g., [behavior][utility][ui][data][combat][ai])]
        ///   Version:       [VersionNumber (e.g., 1.0)] — [YYYY-MM-DD (date of last significant update)]
        ///   Dependencies:  [List any other scripts, objects, or assets this script directly depends on to function correctly (e.g., scr_inventory_add, obj_resource_node). Use "none" if no direct dependencies.]
        ```
    - **Function Encapsulation:** The entire script logic should be contained within a function named identically to the script file (e.g., `function scr_player_movement(argument1, argument2)`).
    - **Numbered Sections with `#region`:** Code within the function must be organized into the following standard, numbered sections using `#region` and `#endregion` for collapsibility and logical flow. Sub-regions (e.g., `#region 0.1 Sub-section Title`) are encouraged for further granularity.
        1.  `// =========================================================================`
        2.  `// 0. IMPORTS & CACHES`
        3.  `// =========================================================================`
        4.  `#region 0.1 Imports & Cached Locals`
            // (Cache frequently used functions, global variables, or instance variables here)
        5.  `#endregion`
        6.  `// =========================================================================`
        7.  `// 1. VALIDATION & EARLY RETURNS`
        8.  `// =========================================================================`
        9.  `#region 1.1 Parameter Validation`
            // (Check validity of arguments, instance existence, etc. Use show_debug_message() for errors and return early.)
        10. `#endregion`
        11. `// =========================================================================`
        12. `// 2. CONFIGURATION & CONSTANTS`
        13. `// =========================================================================`
        14. `#region 2.1 Local Constants`
            // (Define any local constants specific to this script's operation.)
        15. `#endregion`
        16. `// =========================================================================`
        17. `// 3. INITIALIZATION & STATE SETUP`
        18. `// =========================================================================`
        19. `#region 3.1 One-Time Setup / State Variables`
            // (Code for one-time initialization if the script manages persistent state across calls, or setup of state variables.)
        20. `#endregion`
        21. `// =========================================================================`
        22. `// 4. CORE LOGIC`
        23. `// =========================================================================`
        24. `#region 4.1 Main Behavior / Utility Logic`
            // (The primary operations of the script. Can be further sub-divided with lettered regions: a), b), c) etc.)
        25. `#endregion`
        26. `// =========================================================================`
        27. `// 5. CLEANUP & RETURN`
        28. `// =========================================================================`
        29. `#region 5.1 Cleanup & Return Value`
            // (Perform any necessary cleanup, then return the result.)
        30. `#endregion`
        31. `// =========================================================================`
        32. `// 6. DEBUG/PROFILING (Optional)`
        33. `// =========================================================================`
        34. `#region 6.1 Debug & Profile Hooks`
            // (Optional section for debug messages, profiling code.)
        35. `#endregion`
    - **Error Reporting:** Use `show_debug_message("ERROR: script_name() — Specific error message");` for reporting issues during validation or execution.

---

## 5. Notes & Other Text Documents

### 5.1. Format
- **Markdown:** Preferred for structured notes, research, and documentation that benefits from formatting (headings, lists, links).
- **Plain Text (.txt):** Suitable for quick, unstructured notes, to-do lists, or raw data.

### 5.2. Content
- **Date Your Notes:** Especially for research or evolving ideas, include a date.
- **Context:** Briefly state the purpose or context of the note at the beginning.
- **Source Links:** If notes are based on external resources, include links.

---

## 6. Version Control (Git)

Effective use of version control is crucial for tracking changes, collaborating, and recovering from errors.

### 6.1. Commit Messages
- **Follow Conventional Commits:** This provides a clear and consistent commit history. The basic format is:
    `type(scope): short description (imperative mood)`
    - **Types:** `feat` (new feature), `fix` (bug fix), `docs` (documentation changes), `style` (code style changes, formatting), `refactor` (code changes that neither fix a bug nor add a feature), `perf` (performance improvements), `test` (adding or fixing tests), `chore` (build process, auxiliary tools, etc.).
    - **Scope (Optional):** The part of the codebase affected (e.g., `feat(inventory): add item stacking`).
    - **Short Description:** Concise summary of the change. Start with a verb in the imperative mood (e.g., "Add," "Fix," "Change," not "Added," "Fixed," "Changes").
- **Body (Optional):** Provide more context after a blank line, explaining the *what* and *why* of the change if it's complex.
- **Example:**
    ```
    feat(pop_ai): implement basic foraging behavior

    Pops can now identify and move towards obj_redBerryBush
    when their hunger is below 50%. This commit adds the
    scr_pop_find_foraging_target and updates the main pop
    state machine.
    ```

### 6.2. Committing Practices
- **Atomic Commits:** Each commit should represent a single logical change. Avoid bundling unrelated changes into one commit.
- **Commit Often:** Don't wait too long to commit your work. Frequent small commits are better than infrequent large ones.
- **Test Before Committing:** Ensure your changes don't break existing functionality (if applicable).

### 6.3. Branching (Simplified)
- **Main Branch (`main` or `master`):** Should always represent a stable, working version of the project.
- **Feature Branches:** Create new branches for developing new features or making significant changes (e.g., `feature/language-system`, `fix/inventory-bug`).
- **Merge Regularly:** Merge feature branches back into the main branch once they are complete and tested.

By adhering to these guidelines, we can maintain a well-organized, understandable, and easy-to-navigate set of project documents and a clean version history.
