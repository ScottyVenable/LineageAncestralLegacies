/// scr_resources.gml
///
/// Purpose:
///   Defines the `Resource` enum and provides the function `get_resource_data()`
///   to retrieve base data for all defined resource types. It also initializes
///   and stores the master resource database with safe sprite fallbacks.
///
/// Metadata:
///   Summary:       Resource enumerations and data definitions with placeholder sprite logic.
///   Usage:         The `Resource` enum is global. Call `get_resource_data(Resource.ENUM_VALUE)` anywhere.
///                  e.g., var _berry_data = get_resource_data(Resource.RED_BERRY_BUSH);
///   Parameters:    (for get_resource_data) _resource_enum_id : enum.Resource — The enum ID of the resource.
///   Returns:       (for get_resource_data) struct | undefined — A struct containing base properties for the resource, or undefined if not found.
///   Tags:          [data][resources][database][definitions][enums][sprites][initialization]
///   Version:       1.2 - 2025-05-23 // Aligned with TEMPLATE_SCRIPT structure.
///   Dependencies:  Sprite assets (e.g., spr_red_berry_icon, spr_placeholder_icon). Assumes these exist.
///   Creator:       Your Name / GameDev AI // Please update as appropriate
///   Created:       Unknown // Please specify creation date if known
///   Last Modified: 2025-05-23 by Copilot // Updated to match template

// =========================================================================
// 0. IMPORTS & CACHES (Script-level, not for functions within)
// =========================================================================
#region 0.1 Global Enums & Constants
// Define the Resource enum. This makes it globally accessible.
// It's good practice to define enums at the top of a script that primarily manages them.
enum Resource {
    NONE, // Represents a null or default resource, useful for uninitialized states.
    
    // Natural Resources - Food
    RED_BERRY_BUSH, // A bush that provides red berries.
    // Natural Resources - Materials
    TREE,           // A tree that can be harvested for wood.
    STONE_MINE,     // A deposit of stones.
    IRON_MINE,      // A deposit of iron ore.
    // Other
    CARCASS,        // The remains of an animal, potentially providing food or materials.
}
show_debug_message("Enum 'Resource' (from scr_resources.gml) Initialized.");
#endregion

// =========================================================================
// 1. VALIDATION & EARLY RETURNS (Not applicable at script top-level)
// =========================================================================
// This section is typically for functions. Script-level execution flows directly.

// =========================================================================
// 2. CONFIGURATION & CONSTANTS (Script-level)
// =========================================================================
#region 2.1 Script-Level Constants & Configuration
// No script-level specific constants defined here, as most data is within the database initialization.
// Placeholder sprite name, used if a resource's specific sprite is missing.
// It's good to define this clearly if it's used by the initialization logic.
// static global_placeholder_sprite = spr_placeholder_icon; // Example if it were a global script var
#endregion

// =========================================================================
// 3. INITIALIZATION & STATE SETUP (Script-level)
// =========================================================================
#region 3.1 Script-Level Initialization
// The primary initialization is the resource_database, handled within get_resource_data via a static variable.
// This ensures it's initialized only once upon the first call.
// Any other one-time setup for the resource system could go here.
#endregion

// =========================================================================
// 4. CORE LOGIC (Function Definitions)
// =========================================================================
#region 4.1 Main Data Access Function: get_resource_data()

/// @function get_resource_data(_resource_enum_id)
/// @description Retrieves a struct containing the base properties for the given resource enum ID.
///              This function uses a static internal database, initialized on the first call.
/// @param {enum.Resource} _resource_enum_id The enum ID of the resource (e.g., Resource.RED_BERRY_BUSH).
/// @returns {Struct|undefined} A struct with resource data, or undefined if the enum ID is not found in the database.
function get_resource_data(_resource_enum_id) {
    // -------------------------------------------------------------------------
    // 4.1.0. IMPORTS & CACHES (Function-local)
    // -------------------------------------------------------------------------
    // No specific imports needed beyond global scope.
    // The resource_database is static, so it's cached after the first call.

    // -------------------------------------------------------------------------
    // 4.1.1. VALIDATION & EARLY RETURNS (Function-local)
    // -------------------------------------------------------------------------
    // Basic validation for the input parameter type could be added if strictness is required,
    // e.g., checking if _resource_enum_id is a real number (enums are reals).
    // if (!is_real(_resource_enum_id)) {
    //     show_debug_message("ERROR (get_resource_data): _resource_enum_id is not a real number. Enum expected.");
    //     return undefined;
    // }

    // -------------------------------------------------------------------------
    // 4.1.2. CONFIGURATION & CONSTANTS (Function-local)
    // -------------------------------------------------------------------------
    // The static struct ensures the database is built only once.
    // This is a common GameMaker pattern for creating singleton-like data structures.
    static resource_database = __internal_init_resource_database(); 
    
    // -------------------------------------------------------------------------
    // 4.1.3. INITIALIZATION & STATE SETUP (Function-local)
    // -------------------------------------------------------------------------
    // Initialization is handled by the static resource_database line above.

    // -------------------------------------------------------------------------
    // 4.1.4. CORE LOGIC (Function-local)
    // -------------------------------------------------------------------------
    // Attempt to access the data for the given resource enum ID from the database.
    // Using struct_exists provides a safe way to check before accessing.
    if (struct_exists(resource_database, _resource_enum_id)) {
        return resource_database[$ _resource_enum_id]; // Return the data struct for the resource.
    }
    
    // If the resource_enum_id is not found in the database, show a warning and return undefined.
    // This helps in debugging if a new enum value was added but not its data.
    show_debug_message(string_format("WARNING (get_resource_data): No data found for resource enum ID: {0} (Numeric Value: {1}). Ensure it's defined in __internal_init_resource_database().", _resource_enum_id, real(_resource_enum_id)));
    return undefined; 
    
    // -------------------------------------------------------------------------
    // 4.1.5. CLEANUP & RETURN (Function-local)
    // -------------------------------------------------------------------------
    // Return is handled above. No specific cleanup needed for this function.
}
#endregion

#region 4.1.1 Internal Sprite Helper: _get_sprite_or_placeholder()

/// @function _get_sprite_or_placeholder(_sprite_to_check)
/// @description (Internal Helper for scr_resources) Checks if a sprite asset exists.
///              If so, returns it. Otherwise, logs a warning and attempts to return a
///              globally defined placeholder sprite (`spr_placeholder_icon`).
///              If the placeholder also doesn't exist, logs an error and returns `undefined`.
///              This function is intended for use within `__internal_init_resource_database`
///              to ensure all resources have a valid sprite assigned.
/// @param {Asset.GMSprite} _sprite_to_check  The sprite asset index to validate.
/// @returns {Asset.GMSprite|undefined} The validated sprite asset, the placeholder, or undefined if both fail.
static _get_sprite_or_placeholder = function(_sprite_to_check) {
    // Assumes spr_placeholder_icon is the designated global placeholder sprite.
    // This sprite should be available in the project.
    var _placeholder_sprite = spr_placeholder_icon;

    // Check if the requested sprite exists and is valid.
    if (sprite_exists(_sprite_to_check)) {
        return _sprite_to_check; // Sprite is valid, return it.
    } else {
        // The requested sprite was not found. Log a warning.
        // We use _sprite_to_check directly in the log as its name might not be retrievable if it's an invalid ID.
        var _placeholder_sprite_name_for_log = sprite_exists(_placeholder_sprite) ? sprite_get_name(_placeholder_sprite) : "spr_placeholder_icon (MISSING!)";
        // Using debug_log for consistency with project's logging.
        debug_log($"Warning: Requested sprite (Asset ID: '{_sprite_to_check}') not found in scr_resources. Attempting to use placeholder: '{_placeholder_sprite_name_for_log}'.", "ResourceDB", "yellow");

        // Attempt to use the placeholder sprite.
        if (sprite_exists(_placeholder_sprite)) {
            return _placeholder_sprite; // Placeholder is valid, return it.
        } else {
            // Critical error: The placeholder sprite itself is missing.
            debug_log($"ERROR: Placeholder sprite 'spr_placeholder_icon' also not found! Check that 'spr_placeholder_icon' exists in the project. Cannot assign sprite for Asset ID '{_sprite_to_check}'.", "ResourceDB", "red");
            return undefined; // Return undefined as a last resort. This helps prevent crashes but indicates a missing asset.
        }
    }
}
#endregion // End of 4.1.1 Internal Sprite Helper

#region 4.2 Internal Helper Function: __internal_init_resource_database()

/// @function __internal_init_resource_database()
/// @description (Internal Use Only) Initializes and returns the master resource database struct.
///              This function is called once by `get_resource_data` to populate its static database.
///              It defines all properties for each resource in the `Resource` enum.
/// @returns {Struct} The fully populated resource database.
function __internal_init_resource_database() {
    // This function is prefixed with __ to indicate it's intended for internal use within this script.
    show_debug_message("Initializing Resource Database (scr_resources.gml) with sprite fallback logic...");
    var _db = {}; // Start with an empty struct, which will serve as our database.

    // --- Inline Helper function to safely get a sprite index or return a placeholder --- 
    // This helper is defined inside __internal_init_resource_database to keep it local
    // and prevent polluting the global namespace. It encapsulates the logic for sprite checking.
    // Renamed to `_resolve_sprite_for_init` to avoid a potential name collision
    // with the script-level static function `_get_sprite_or_placeholder`.
    // This collision was likely the cause of the "variable not set" error.
    var _resolve_sprite_for_init = function(sprite_asset_name_or_index) {
        // Static variables within this anonymous function ensure these checks run only once *per game run*,
        // not per call to _resolve_sprite_for_init, optimizing the placeholder check.
        static _placeholder_sprite_index = spr_placeholder_icon; // Cache the placeholder sprite index.
        static _placeholder_exists_and_valid = false;
        static _placeholder_checked = false;

        if (!_placeholder_checked) {
            _placeholder_exists_and_valid = sprite_exists(_placeholder_sprite_index);
            if (!_placeholder_exists_and_valid) {
                // Using debug_log for consistency and better tagging.
                // This is a critical warning: if the main placeholder is missing, many things might lack icons.
                debug_log("CRITICAL: The primary spr_placeholder_icon is MISSING! Resources may lack icons if their specific sprites are also missing.", "ResourceDB Init", "red");
            }
            _placeholder_checked = true;
        }

        var _sprite_to_check = -1; // Default to an invalid sprite index.
        var _original_input_string = "(not a string)"; // For logging purposes.

        if (is_string(sprite_asset_name_or_index)) { // If a string (asset name) is provided.
            _original_input_string = sprite_asset_name_or_index;
            _sprite_to_check = asset_get_index(sprite_asset_name_or_index); // Convert name to index.
        } else if (is_real(sprite_asset_name_or_index)) { // If a number (direct sprite index) is provided.
            _sprite_to_check = sprite_asset_name_or_index;
            // Attempt to get the name for logging, if it's a valid sprite index.
            if (sprite_exists(_sprite_to_check)) {
                _original_input_string = sprite_get_name(_sprite_to_check);
            } else {
                _original_input_string = "(invalid direct index: " + string(_sprite_to_check) + ")";
            }
        } else {
            // If the input is neither a string nor a real number, it's invalid.
            // Using debug_log, correcting message, and variable name.
            debug_log($"Invalid input type for sprite_asset_name_or_index: '{sprite_asset_name_or_index}'. Expected string or real. Using placeholder.", "ResourceDB Init", "yellow");
            return _placeholder_exists_and_valid ? _placeholder_sprite_index : -1; // Return placeholder or -1.
        }
	}
        
        // Now, check if the determined _sprite_to_check actually exists.
        if (sprite_exists(_sprite_to_check)) {
            return _sprite_to_check; // Sprite found, return its index.
        }
        
        // Fallback: Sprite does not exist. Use placeholder if available.
        if (_placeholder_exists_and_valid) {
            // Log a warning if the intended sprite was not the placeholder itself and was not explicitly -1 (noone).
            if (_sprite_to_check != _placeholder_sprite_index && _sprite_to_check != -1) {
                 // Using debug_log for consistency.
                 debug_log(string_format("Sprite '{0}' (resolved index: {1}) not found. Using placeholder spr_placeholder_icon.", _original_input_string, _sprite_to_check), "ResourceDB Init", "yellow");
            }
            return _placeholder_sprite_index;
        } else {
            // Critical situation: specific sprite missing AND placeholder sprite missing.
            if (_sprite_to_check != -1) { // Only log if we were expecting a specific sprite.
                // Using debug_log for consistency.
                debug_log(string_format("Sprite '{0}' (resolved index: {1}) not found, AND spr_placeholder_icon is also missing! Returning -1 (no icon).", _original_input_string, _sprite_to_check), "ResourceDB Init", "red");
            }
            return -1; // Absolute fallback: no icon available.
        }
    };
    // --- End of inline helper function _resolve_sprite_for_init ---


    // --- DEFINE ALL RESOURCE PROPERTIES HERE using the Resource enum as keys ---
    // This is where you map each enum member to its data struct.

    // Example: Resource.RED_BERRY_BUSH
    _db[$ Resource.RED_BERRY_BUSH] = {
        name: "Red Berry Bush",                                  // Human-readable name.
        description: "A common bush yielding edible red berries. Found in temperate areas.", // In-game description.
        sprite_icon: _resolve_sprite_for_init(spr_redBerryBush_full), // Icon sprite. spr_redBerryBush_full should be your asset name.
        resource_count: 20,                                  // Max items this node can hold or yield at once.
        resource_category: "Food",                           // Broad category (e.g., Food, Wood, Stone, Ore).
        resource_tags: ["food", "raw", "plant", "forageable"], // Specific tags for filtering or mechanics.
        regenerates: true,                                   // Does this resource node replenish itself?
        regenerate_duration: 3,                              // Time (in game ticks or seconds) to regenerate one unit, if applicable.
        regenerate_delay: 200,                               // Time (in game ticks or seconds) before regeneration starts after depletion.
        // Add other relevant properties like: tool_required, skill_required, yield_item_enum, yield_quantity_min/max etc.
    };

    // Example: Resource.TREE (assuming spr_tree_icon exists or placeholder will be used)
    _db[$ Resource.TREE] = {
        name: "Tree",
        description: "A sturdy tree. Can be chopped for wood.",
        sprite_icon: _resolve_sprite_for_init("spr_tree_icon"), // Example using a string name
        resource_count: 50, // e.g., total wood units
        resource_category: "Wood",
        resource_tags: ["wood", "material", "choppable"],
        regenerates: false, // Or true if they regrow, then add regeneration properties
        // tool_required: Item.AXE, // Example dependency
        // yield_item_enum: Item.WOOD_LOG,
        // yield_quantity_min: 3,
        // yield_quantity_max: 5,
    };
    
    // Example: Resource.STONE_MINE (assuming spr_stone_mine_icon exists)
    _db[$ Resource.STONE_MINE] = {
        name: "Stone Deposit",
        description: "A rocky outcrop rich in stone.",
        sprite_icon: _resolve_sprite_for_init(spr_stone_mine_icon),
        resource_count: 100, // e.g., total stone units
        resource_category: "Stone",
        resource_tags: ["stone", "material", "mineable"],
        regenerates: false, // Typically mines don't regenerate quickly
        // tool_required: Item.PICKAXE,
        // yield_item_enum: Item.STONE,
        // yield_quantity_min: 2,
        // yield_quantity_max: 4,
    };

    // ... ADD ALL OTHER RESOURCE DEFINITIONS HERE ...
    // For Resource.IRON_MINE, Resource.CARCASS, etc., following the same pattern.
    // Ensure every member of your Resource enum has a corresponding entry in _db.

    // Using debug_log for consistency and corrected formatting.
    debug_log($"Resource Database Initialized. {struct_names_count(_db)} resource types defined.", "ResourceDB Init", "green");
    return _db; // Return the populated database.
#endregion

// =========================================================================
// 5. CLEANUP & RETURN (Not applicable at script top-level for definitions)
// =========================================================================

// =========================================================================
// 6. DEBUG/PROFILING (Script-level, e.g., initial checks)
// =========================================================================
#region 6.1 Script-Level Debug Checks
// You could add a check here to ensure all enum values are in the database upon game start,
// but it's tricky because the database initializes lazily. A dedicated test script might be better.
// show_debug_message("scr_resources.gml fully parsed.");
#endregion