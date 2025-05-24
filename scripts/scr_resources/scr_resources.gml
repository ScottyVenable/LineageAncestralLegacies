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
// Using debug_log for consistency with project's logging.
// Assumes debug_log can take (message, category, level/color).
debug_log("Enum 'Resource' initialized.", "ResourceSystem", "info");
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
    // 4.1.0. IMPORTS & CACHES (Function-level)
    // -------------------------------------------------------------------------
    // No specific imports needed beyond global scope.
    // The resource_database is static, so it's cached after the first call.

    // -------------------------------------------------------------------------
    // 4.1.1. VALIDATION & EARLY RETURNS (Function-level)
    // -------------------------------------------------------------------------
    // Basic validation for the input parameter type could be added if strictness is required,
    // e.g., checking if _resource_enum_id is a real number (enums are reals).
    // if (!is_real(_resource_enum_id)) {
    //     show_debug_message("ERROR (get_resource_data): _resource_enum_id is not a real number. Enum expected.");
    //     return undefined;
    // }

    // -------------------------------------------------------------------------
    // 4.1.2. CONFIGURATION & CONSTANTS (Function-level)
    // -------------------------------------------------------------------------
    // The static struct ensures the database is built only once.
    // This is a common GameMaker pattern for creating singleton-like data structures.
    static resource_database = __internal_init_resource_database(); 
    
    // -------------------------------------------------------------------------
    // 4.1.3. INITIALIZATION & STATE SETUP (Function-level)
    // -------------------------------------------------------------------------
    // Initialization is handled by the static resource_database line above.

    // -------------------------------------------------------------------------
    // 4.1.4. CORE LOGIC (Function-level)
    // -------------------------------------------------------------------------
    // Attempt to access the data for the given resource enum ID from the database.
    // Using struct_exists provides a safe way to check before accessing.
    if (struct_exists(resource_database, _resource_enum_id)) {
        return resource_database[$ _resource_enum_id]; // Return the data struct for the resource.
    }
    
    // If the resource_enum_id is not found in the database, show a warning and return undefined.
    // This helps in debugging if a new enum value was added but not its data.
    // Using debug_log for consistency.
    debug_log(string_format("No data found for resource enum ID: {0} (Value: {1}). Ensure it's defined in __internal_init_resource_database.", _resource_enum_id, real(_resource_enum_id)), "ResourceSystem", "yellow");
    return undefined; 
    
    // -------------------------------------------------------------------------
    // 4.1.5. CLEANUP & RETURN (Function-local)
    // -------------------------------------------------------------------------
    // Return is handled above. No specific cleanup needed for this function.
}
#endregion

#region 4.1.1 Internal Sprite Helper: _get_sprite_or_placeholder()

/// @function _get_sprite_or_placeholder(_asset_name_or_index)
/// @description (Internal Helper for scr_resources) Checks if a sprite asset exists by name or index.
///              If so, returns its index. Otherwise, logs a warning and attempts to return a
///              globally defined placeholder sprite (`spr_placeholder_icon`).
///              If the placeholder also doesn't exist, logs an error and returns -1.
///              This function is intended for robust sprite fetching within the resource system.
/// @param {Asset.GMSprite|String} _asset_name_or_index  The sprite asset index (real) or name (string) to validate.
/// @returns {Asset.GMSprite} The validated sprite asset index, the placeholder's index, or -1 if all fail.
function _get_sprite_or_placeholder(_asset_name_or_index) {
    // Static cache for placeholder sprite information.
    // This ensures spr_placeholder_icon is checked only once per game run for efficiency.
    static _placeholder_sprite_index = spr_placeholder_icon; // Direct asset reference.
    static _placeholder_is_valid = undefined; // Undefined initially, so the check runs on first call.

    if (is_undefined(_placeholder_is_valid)) { // Check placeholder status only once.
        _placeholder_is_valid = sprite_exists(_placeholder_sprite_index);
        if (!_placeholder_is_valid) {
            // This is a critical issue if the main fallback sprite is missing.
            debug_log("CRITICAL: Placeholder sprite 'spr_placeholder_icon' is missing or invalid! Resource icons may be affected.", "ResourceSystem", "red");
        }
    }

    var _sprite_index_to_check = -1; // Default to an invalid sprite index.
    var _input_identifier_for_log = ""; // Stores the original input for clearer log messages.

    if (is_string(_asset_name_or_index)) { // Input is a sprite asset name (string).
        _input_identifier_for_log = _asset_name_or_index;
        _sprite_index_to_check = asset_get_index(_asset_name_or_index); // Convert name to index.
        if (_sprite_index_to_check == -1) { // asset_get_index returns -1 if the name is not found.
            debug_log($"Sprite asset name '{_input_identifier_for_log}' not found in project assets. Will attempt to use placeholder.", "ResourceSystem", "yellow");
            // No need to check sprite_exists for -1; proceed to placeholder logic.
        }
    } else if (is_real(_asset_name_or_index)) { // Input is a sprite asset index (real number).
        _sprite_index_to_check = _asset_name_or_index;
        // For logging, use the index itself or try to get its name if it's a known valid sprite.
        _input_identifier_for_log = sprite_exists(_sprite_index_to_check) ? sprite_get_name(_sprite_index_to_check) : "Sprite Index " + string(_sprite_index_to_check);
    } else { // Input is neither a string nor a real number.
        _input_identifier_for_log = string(_asset_name_or_index) + " (invalid type)";
        debug_log($"Invalid input type for sprite: '{_input_identifier_for_log}'. Expected string (asset name) or real (sprite index). Will attempt to use placeholder.", "ResourceSystem", "orange");
        // Proceed to placeholder logic.
    }

    // Check if the resolved sprite index is valid (not -1) and the sprite actually exists.
    if (_sprite_index_to_check != -1 && sprite_exists(_sprite_index_to_check)) {
        return _sprite_index_to_check; // Requested sprite found and valid.
    }

    // Requested sprite was not found, was invalid, or input type was wrong.
    // Log a warning if we were trying to find a specific sprite that wasn't found,
    // unless it was an asset name that asset_get_index already flagged as not found.
    if (!is_string(_asset_name_or_index) || asset_get_index(_asset_name_or_index) != -1) {
        // This condition avoids double-logging for asset names that asset_get_index already reported as not found.
        // It logs if the input was a direct index that failed, or an asset name that *was* found by asset_get_index but then failed sprite_exists (rare).
        if (_sprite_index_to_check != -1) { // Only log if we had a potentially valid ID to check.
             debug_log($"Requested sprite '{_input_identifier_for_log}' (Resolved ID: {_sprite_index_to_check}) not found or invalid. Attempting to use placeholder.", "ResourceSystem", "yellow");
        }
    }
    
    // Attempt to use the placeholder sprite.
    if (_placeholder_is_valid) {
        return _placeholder_sprite_index; // Placeholder is valid, return its index.
    }

    // Both the requested sprite and the placeholder are unavailable.
    // The critical message about placeholder missing is logged once when _placeholder_is_valid is first set.
    // Log an additional error if a specific sprite was requested AND the placeholder is also missing.
    if (_sprite_index_to_check != -1) { // Only if we were actually looking for a specific sprite (not just bad input type or unfound asset name).
         debug_log($"Error: Sprite '{_input_identifier_for_log}' is missing, AND placeholder 'spr_placeholder_icon' is also missing. No icon can be assigned (-1).", "ResourceSystem", "red");
    }
    return -1; // Absolute fallback: return -1 (noone / invalid sprite).
}
#endregion // End of 4.1.1 Internal Sprite Helper

#region 4.2 Internal Helper Function: __internal_init_resource_database()

/// @function __internal_init_resource_database()
/// @description (Internal Use Only) Initializes and returns the master resource database struct.
///              This function is called once by `get_resource_data` to populate its static database.
///              It defines all properties for each resource in the `Resource` enum.
///              Uses the script-level `_get_sprite_or_placeholder` for robust icon fetching.
/// @returns {Struct} The fully populated resource database.
function __internal_init_resource_database() {
    // This function is prefixed with __ to indicate it's intended for internal use within this script.
    debug_log("Initializing Resource Database...", "ResourceSystem", "info"); // Standardized logging
    var _db = {}; // Start with an empty struct, which will serve as our database.

    // --- DEFINE ALL RESOURCE PROPERTIES HERE using the Resource enum as keys ---
    // This is where you map each enum member to its data struct.
    // It now directly uses the script-level `_get_sprite_or_placeholder` function.

    // Example: Resource.RED_BERRY_BUSH
    _db[$ Resource.RED_BERRY_BUSH] = {
        name: "Red Berry Bush",                                  // Human-readable name.
        description: "A common bush yielding edible red berries. Found in temperate areas.", // In-game description.
        sprite_icon: _get_sprite_or_placeholder(spr_redBerryBush_full), // Icon sprite. spr_redBerryBush_full should be your asset name.
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
        sprite_icon: _get_sprite_or_placeholder("spr_tree_icon"), // Example using a string name
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
        sprite_icon: _get_sprite_or_placeholder(spr_stone_mine_icon),
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
    debug_log($"Resource Database Initialized. {struct_names_count(_db)} resource types defined.", "ResourceSystem", "info"); // Changed from green to info for consistency
    return _db; // Return the populated database.
}
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