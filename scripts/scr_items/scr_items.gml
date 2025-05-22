/// scr_items.gml
///
/// Purpose:
///    Defines the Item enum and provides the function get_item_data()
///    to retrieve base data for all defined item types.
///    Initializes and stores the master item database with safe sprite fallbacks.
///
/// Metadata:
///   Summary:       Item enumerations and data definitions with placeholder sprite logic.
///   Usage:         Enum Item is global. Call get_item_data(Item.ENUM_VALUE) anywhere.
///   Tags:          [data][items][database][definitions][enums][sprites]
///   Version:       1.1 - [Current Date] // Added placeholder sprite logic
///   Dependencies:  Sprite assets (e.g., spr_red_berry_icon, spr_placeholder_icon).

// ============================================================================
// 1. ITEM ENUMERATION
// ============================================================================
#region 1.1 Item Enum Definition
enum Item {
    NONE, // Default/Null item
    
    // Food
    FOOD_RED_BERRY,
    FOOD_ROAST_MEAT, // Example
    
    // Materials
    MATERIAL_STONE,
    MATERIAL_WOOD,
    MATERIAL_FLINT,  // Example
    MATERIAL_METAL_ORE, // Example
    
    // Tools
    TOOL_STONE_AXE,
    TOOL_STONE_PICKAXE, // Example
    TOOL_WOODEN_SPEAR, // Example
    
    // Crafted Goods / Other
    MISC_ROPE, // Example
    MISC_BASKET // Example
    // ... add all your items ...
}
show_debug_message("Enum 'Item' (scr_items) Initialized.");
#endregion

// ============================================================================
// 2. ITEM DATA ACCESS FUNCTION & DATABASE
// ============================================================================
#region 2.1 get_item_data() Function

/// @function get_item_data(item_enum_id)
/// @description Returns a struct containing the base properties for the given item enum.
/// @param {enum.Item} item_enum_id The enum ID of the item.
/// @returns {Struct|undefined}
function get_item_data(item_enum_id) {
    // The static struct ensures the database is built only once, the first time this function is called.
    static item_database = __internal_init_item_database(); 
    
    if (struct_exists(item_database, item_enum_id)) {
        return item_database[$ item_enum_id];
    }
    show_debug_message($"Warning (get_item_data): No data found for item enum: {item_enum_id} (Value: {real(item_enum_id)}). Did you define it in __internal_init_item_database?");
    return undefined; 
}
#endregion

#region 2.2 __internal_init_item_database() Helper Function

// Helper function to initialize the database (called only once by the static variable in get_item_data)
// Prefixed with __ to indicate it's intended for internal use by this script.
function __internal_init_item_database() {
    show_debug_message("Initializing Item Database within scr_items (with sprite fallback)...");
    var _db = {}; // Start with an empty struct to act as our database

    // --- Inline Helper function to safely get sprite or return placeholder ---
    var _get_sprite_or_placeholder = function(sprite_asset_name_or_index) {
        // Ensure spr_placeholder_icon itself exists first, ONCE.
        static _placeholder_exists_and_valid = false;
        static _placeholder_checked = false;
        if (!_placeholder_checked) {
            _placeholder_exists_and_valid = sprite_exists(spr_placeholder_icon);
            if (!_placeholder_exists_and_valid) {
                show_debug_message_once("CRITICAL WARNING (Item DB): spr_placeholder_icon ITSELF IS MISSING! Items may have no icon if their specific sprite is also missing.");
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
             show_debug_message($"Warning (Item DB _get_sprite): Invalid input '{sprite_asset_name_or_index}' for sprite. Using placeholder.");
             return _placeholder_exists_and_valid ? spr_placeholder_icon : -1;
        }
        
        if (sprite_exists(_sprite_to_check)) {
            return _sprite_to_check; // Sprite found, return it
        }
        
        // Fallback if sprite doesn't exist
        if (_placeholder_exists_and_valid) {
            // Log warning only if the intended sprite was not the placeholder itself and was not -1 (noone)
            if (_sprite_to_check != spr_placeholder_icon && _sprite_to_check != -1) {
                 show_debug_message($"Warning (Item DB): Sprite '{_original_input_string}' (Index: {_sprite_to_check}) not found. Using spr_placeholder_icon.");
            }
            return spr_placeholder_icon;
        } else {
            // No specific sprite, and no placeholder either
            if (_sprite_to_check != -1) { // Only log if we were expecting a specific sprite
                show_debug_message($"Warning (Item DB): Sprite '{_original_input_string}' (Index: {_sprite_to_check}) not found, AND spr_placeholder_icon is missing!");
            }
            return -1; // Absolute fallback (no icon)
        }
    };
    // --- End of inline helper function ---


    // --- DEFINE ALL ITEM PROPERTIES HERE ---

    // Example: FOOD_RED_BERRY
    _db[$ Item.FOOD_RED_BERRY] = {
        name: "Wild Berry",
        description: "A small, sweet red berry, good for a quick snack.",
        sprite_icon: _get_sprite_or_placeholder(spr_red_berry_icon), // Use the helper; spr_red_berry_icon should be your asset
        max_stack: 25,
        weight_per_unit: 0.05,
        item_category: "Consumable",         
        item_tags: ["food", "raw", "plant"], 
        effects_on_consume: {                
            hunger_restore: 15,
            thirst_restore: 5,
            health_change: 0 
        }
    };

    // Example: TOOL_STONE_AXE
    _db[$ Item.TOOL_STONE_AXE] = {
        name: "Stone Axe",
        description: "A crude axe made of stone lashed to a sturdy branch. Good for chopping wood.",
        sprite_icon: _get_sprite_or_placeholder("spr_tool_stone_axe"), // spr_tool_stone_axe should be your asset
        max_stack: 1,                        
        weight_per_unit: 1.5,
        item_category: "Tool",
        item_tags: ["tool", "axe", "woodcutting", "melee_weapon_crude"],
        equip_slot: "hand_main",             
        durability_max: 100,
        damage_melee: 4,                     
        effectiveness: {                     
            woodcutting: 1.2,                
            mining: 0.5                      
        } 
    };

    // Example: MATERIAL_WOOD
    _db[$ Item.MATERIAL_WOOD] = {
        name: "Wood Log",
        description: "A rough log of wood, useful for building and fuel.",
        sprite_icon: _get_sprite_or_placeholder("spr_material_wood_log"), // spr_material_wood_log should be your asset
        max_stack: 50,
        weight_per_unit: 0.8,
        item_category: "Material",
        item_tags: ["material", "wood", "building", "fuel"]
    };
    
    // Example: MATERIAL_STONE
     _db[$ Item.MATERIAL_STONE] = {
        name: "Stone Chunk",
        description: "A fist-sized piece of rock.",
        sprite_icon: _get_sprite_or_placeholder("spr_material_stone_chunk"), // MAKE SURE spr_material_stone_chunk EXISTS
        max_stack: 50,
        weight_per_unit: 1.0,
        item_category: "Material",
        item_tags: ["material", "stone", "building", "crafting"]
    };

    // ... ADD ALL OTHER ITEM DEFINITIONS HERE, using the _get_sprite_or_placeholder() for sprite_icon ...
    // Ensure every member of your Item enum has a corresponding entry here.
    // If an item intentionally has NO icon, you can pass -1 or noone to _get_sprite_or_placeholder,
    // or handle it specially if needed (e.g., sprite_icon: -1 directly).

    show_debug_message($"Item Database Initialized from scr_items. {struct_names_count(_db)} items defined.");
    return _db;
}
#endregion