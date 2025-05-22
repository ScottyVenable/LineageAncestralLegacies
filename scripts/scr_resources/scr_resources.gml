/// scr_resources.gml
///
/// Purpose:
///    Defines the Resource enum and provides the function get_resource_data()
///    to retrieve base data for all defined resource types.
///    Initializes and stores the master resource database with safe sprite fallbacks.
///
/// Metadata:
///   Summary:       Resource enumerations and data definitions with placeholder sprite logic.
///   Usage:         Enum Resource is global. Call get_resource_data(Resource.ENUM_VALUE) anywhere.
///   Tags:          [data][resources][database][definitions][enums][sprites]
///   Version:       1.1 - [Current Date] // Added placeholder sprite logic
///   Dependencies:  Sprite assets (e.g., spr_red_berry_icon, spr_placeholder_icon).

// ============================================================================
// 1. ITEM ENUMERATION
// ============================================================================
#region 1.1 Resource Enum Definition
enum Resource {
    NONE, // Default/Null resource
    
    // Food
    RED_BERRY_BUSH,
    TREE,
	STONE_MINE,
	IRON_MINE,
	CARCASS,
}
show_debug_message("Enum 'Resource' (scr_resources) Initialized.");
#endregion

// ============================================================================
// 2. ITEM DATA ACCESS FUNCTION & DATABASE
// ============================================================================
#region 2.1 get_resource_data() Function

/// @function get_resource_data(resource_enum_id)
/// @description Returns a struct containing the base properties for the given resource enum.
/// @param {enum.Resource} resource_enum_id The enum ID of the resource.
/// @returns {Struct|undefined}
function get_resource_data(resource_enum_id) {
    // The static struct ensures the database is built only once, the first time this function is called.
    static resource_database = __internal_init_resource_database(); 
    
    if (struct_exists(resource_database, resource_enum_id)) {
        return resource_database[$ resource_enum_id];
    }
    show_debug_message($"Warning (get_resource_data): No data found for resource enum: {resource_enum_id} (Value: {real(resource_enum_id)}). Did you define it in __internal_init_resource_database?");
    return undefined; 
}
#endregion

#region 2.2 __internal_init_resource_database() Helper Function

// Helper function to initialize the database (called only once by the static variable in get_resource_data)
// Prefixed with __ to indicate it's intended for internal use by this script.
function __internal_init_resource_database() {
    show_debug_message("Initializing Resource Database within scr_resources (with sprite fallback)...");
    var _db = {}; // Start with an empty struct to act as our database

    // --- Inline Helper function to safely get sprite or return placeholder ---
    var _get_sprite_or_placeholder = function(sprite_asset_name_or_index) {
        // Ensure spr_placeholder_icon itself exists first, ONCE.
        static _placeholder_exists_and_valid = false;
        static _placeholder_checked = false;
        if (!_placeholder_checked) {
            _placeholder_exists_and_valid = sprite_exists(spr_placeholder_icon);
            if (!_placeholder_exists_and_valid) {
                show_debug_message_once("CRITICAL WARNING (Resource DB): spr_placeholder_icon ITSELF IS MISSING! Resources may have no icon if their specific sprite is also missing.");
            }
            _placeholder_checked = true;
        }

        var _sprite_to_check = -1;
        var _original_input_string = "";

        if (is_string(sprite_asset_name_or_index)) { // If a string name is provided
            _original_input_string = sprite_asset_name_or_index;
            _sprite_to_check = asset_get_index(sprite_asset_name_or_index);
        } else if (is_real(sprite_asset_name_or_index)) { // If an index is provided directly
            _sprite_to_check = sprite_asset_name_or_index;
            _original_input_string = sprite_get_name(sprite_asset_name_or_index); // For logging if it fails
        } else {
             show_debug_message($"Warning (Resource DB _get_sprite): Invalid input '{sprite_asset_name_or_index}' for sprite. Using placeholder.");
             return _placeholder_exists_and_valid ? spr_placeholder_icon : -1;
        }
        
        if (sprite_exists(_sprite_to_check)) {
            return _sprite_to_check; // Sprite found, return it
        }
        
        // Fallback if sprite doesn't exist
        if (_placeholder_exists_and_valid) {
            // Log warning only if the intended sprite was not the placeholder itself and was not -1 (noone)
            if (_sprite_to_check != spr_placeholder_icon && _sprite_to_check != -1) {
                 show_debug_message($"Warning (Resource DB): Sprite '{_original_input_string}' (Index: {_sprite_to_check}) not found. Using spr_placeholder_icon.");
            }
            return spr_placeholder_icon;
        } else {
            // No specific sprite, and no placeholder either
            if (_sprite_to_check != -1) { // Only log if we were expecting a specific sprite
                show_debug_message($"Warning (Resource DB): Sprite '{_original_input_string}' (Index: {_sprite_to_check}) not found, AND spr_placeholder_icon is missing!");
            }
            return -1; // Absolute fallback (no icon)
        }
    };
    // --- End of inline helper function ---


    // --- DEFINE ALL ITEM PROPERTIES HERE ---

    // Example: FOOD_RED_BERRY
    _db[$ Resource.RED_BERRY_BUSH] = {
        name: "Red Berry Bush",
        description: "A berry bush containing sweet, red berries",
        sprite_icon: _get_sprite_or_placeholder(spr_redBerryBush_full), // Use the helper; spr_red_berry_icon should be your asset
        resource_count: 20,
        resource_category: "Food",         
        resource_tags: ["food", "raw", "plant"],
		regenerates: true,
		regenerate_duration: 3,
		regenerate_delay: 200,
		
    };


    // ... ADD ALL OTHER ITEM DEFINITIONS HERE, using the _get_sprite_or_placeholder() for sprite_icon ...
    // Ensure every member of your Resource enum has a corresponding entry here.
    // If an resource intentionally has NO icon, you can pass -1 or noone to _get_sprite_or_placeholder,
    // or handle it specially if needed (e.g., sprite_icon: -1 directly).

    show_debug_message($"Resource Database Initialized from scr_resources. {struct_names_count(_db)} resources defined.");
    return _db;
}
#endregion