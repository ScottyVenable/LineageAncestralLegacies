/// scr_item_definitions.gml
///
/// Purpose:
///     Centralized item-definition library. Initializes a global map of all game items
///     organized by category (consumables, materials, equipment), and provides
///     query functions to retrieve any field at runtime. Each item definition
///     now includes a 'sprite_asset' key for its inventory icon, with safe fallbacks.
///     Includes a helper function to create base item definition maps.
///
/// Metadata:
///     Summary:        Initialize and store all item definitions, with robust sprite handling and base definition helper.
///     Usage:          obj_controller Create Event:   scr_item_definitions_init();
///                     Anywhere:                       scr_get_item_definition(item_id);
///                                                     scr_get_item_sprite(item_id);
///     Parameters:     item_id : string — key for the item (e.g., "berry", "stone")
///     Returns:        see each function’s docstring
///     Tags:           [data][utility][items][initialization][definitions]
///     Version:        1.3 — 2024-05-19 // Scotty's current date
///     Dependencies:   ds_map_*, sprite_exists(), asset_get_index(),
///                     spr_placeholder_icon (MUST EXIST), ItemType enum/macros.

//=============================================================================
// 0. GLOBAL DECLARATIONS & HELPER FUNCTIONS
//=============================================================================
#region 0.1 Global Maps
// Master map: item_id (string) → definition map (which is another ds_map or struct)
global.item_defs = undefined;
#endregion

#region 0.2 scr_create_item_base_definition() - Integrated Helper Function
/// @function scr_create_item_base_definition(id_string, name_str, desc_str, type_enum, stack_int, value_real, weight_real)
/// @description Creates a base ds_map structure for an item definition.
/// @param {string} id_string The unique identifier string for the item (e.g., "stone").
/// @param {string} name_str Display name of the item (e.g., "Stone").
/// @param {string} desc_str Description of the item.
/// @param {enum} type_enum ItemType enum value (e.g., ItemType.MATERIAL_STONE).
/// @param {integer} stack_int Maximum stack size.
/// @param {real} value_real Base value or cost.
/// @param {real} weight_real Weight of a single unit.
/// @returns {Id.DsMap} A ds_map containing the base item definition. Returns an empty map on error.
function scr_create_item_base_definition(id_string, name_str, desc_str, type_enum, stack_int, value_real, weight_real) {
    // 1. VALIDATION
    if (argument_count < 7) {
        show_debug_message("ERROR (scr_create_item_base_definition): Incorrect number of arguments. Expected 7, got " + string(argument_count));
        return ds_map_create(); // Return an empty map to prevent further errors
    }

    // 4. CORE LOGIC
    var _base_def_map = ds_map_create();

    ds_map_add(_base_def_map, "id",            id_string);
    ds_map_add(_base_def_map, "name",          name_str);
    ds_map_add(_base_def_map, "description",   desc_str);
    ds_map_add(_base_def_map, "item_type",     type_enum);
    ds_map_add(_base_def_map, "max_stack",     stack_int);
    ds_map_add(_base_def_map, "base_value",    value_real);
    ds_map_add(_base_def_map, "weight",        weight_real);
    
    ds_map_add(_base_def_map, "sprite_asset",  spr_placeholder_icon); // Default, can be overridden
    ds_map_add(_base_def_map, "stats",         undefined);
    ds_map_add(_base_def_map, "effects",       undefined);
    ds_map_add(_base_def_map, "craftable",     false);
    ds_map_add(_base_def_map, "recipe",        undefined);
    ds_map_add(_base_def_map, "equip_slot",    undefined);

    // 5. RETURN
    return _base_def_map;
}
#endregion


//=============================================================================
// 1. INITIALIZATION
//=============================================================================
#region 1.1 scr_item_definitions_init()

/// @function scr_item_definitions_init()
/// @description Create and populate global.item_defs by calling category definition scripts.
///              Ensures this is only run once or safely re-initializes.
function scr_item_definitions_init() {
    #region 1.1.1 Create Master Map
    if (variable_global_exists("item_defs") && 
        global.item_defs != undefined && 
        ds_exists(global.item_defs, ds_type_map)) {
        ds_map_destroy(global.item_defs);
    }
    global.item_defs = ds_map_create();
    #endregion

    #region 1.1.2 Load Categories
    if (!sprite_exists(spr_placeholder_icon)) {
        show_debug_message("CRITICAL ERROR (scr_item_definitions_init): spr_placeholder_icon is MISSING. Item definitions will likely fail or lack icons.");
    }

    scr_item_defs_consumables();
    scr_item_defs_materials(); 
    scr_item_defs_equipment();
    #endregion
    
    show_debug_message("Item definitions initialized. Total items: " + string(ds_map_size(global.item_defs)));
}
#endregion


//=============================================================================
// 2. CATEGORY DEFINITIONS
//=============================================================================

#region 2.1 scr_item_defs_consumables()
/// @function scr_item_defs_consumables()
/// @description Define all consumable items and add them to global.item_defs.
function scr_item_defs_consumables() {
    show_debug_message("scr_item_defs_consumables: Initializing consumable item definitions...");
    var _placeholder_icon_exists = sprite_exists(spr_placeholder_icon); 

    // --- Wild Berry ---
    var def_berry = ds_map_create(); // Consumables might not use the base_definition helper if they are very unique
    ds_map_add(def_berry, "id",          "red_berry"); // Keep ID consistent if not using helper
    ds_map_add(def_berry, "name",        "Wild Berry");
    ds_map_add(def_berry, "description", "A small red edible berry.");
    ds_map_add(def_berry, "weight",      0.1);
    ds_map_add(def_berry, "item_type",   ItemType.CONSUMABLE_FOOD); // Added item type
    ds_map_add(def_berry, "max_stack",   20); // Added max_stack
    
    var _item_specific_sprite_name_berry = "spr_red_berry_icon";
    var _item_specific_sprite_index_berry = asset_get_index(_item_specific_sprite_name_berry);

    if (_item_specific_sprite_index_berry != -1 && sprite_exists(_item_specific_sprite_index_berry)) {
        ds_map_add(def_berry, "sprite_asset", _item_specific_sprite_index_berry);
    } else {
        show_debug_message($"WARNING (scr_item_defs_consumables): Sprite '{_item_specific_sprite_name_berry}' not found for item 'berry'.");
        if (_placeholder_icon_exists) {
            ds_map_add(def_berry, "sprite_asset", spr_placeholder_icon);
        } else {
            ds_map_add(def_berry, "sprite_asset", noone); 
        }
    }
    
    var stats_berry = ds_map_create();
    ds_map_add(stats_berry, "hunger_restore", 10); // Increased hunger restore for example
    ds_map_add(def_berry,   "stats",    stats_berry);
    ds_map_add(def_berry,   "effects",  undefined);
    
    ds_map_add(global.item_defs, "red_berry", def_berry); // Use the ID string as key

    show_debug_message("scr_item_defs_consumables: Finished initializing consumable item definitions.");
}
#endregion


#region 2.2 scr_item_defs_materials()
/// @function scr_item_defs_materials()
/// @description Define all raw material items and add them to global.item_defs.
/// @dependencies scr_create_item_base_definition(), ItemType enum/macros.
function scr_item_defs_materials() {
    show_debug_message("scr_item_defs_materials: Initializing material item definitions...");

    var _placeholder_icon_exists = sprite_exists(spr_placeholder_icon);
    if (!_placeholder_icon_exists) {
        show_debug_message("CRITICAL WARNING (scr_item_defs_materials): spr_placeholder_icon is MISSING. Placeholder system will fail.");
    }

    // ============================================================================
    // Stone Definition
    // ============================================================================
    var def_stone = scr_create_item_base_definition(
        "stone",                                  // id_string
        "Stone",                                  // name_str
        "A common piece of rock. Useful for crafting.", // desc_str
        ItemType.MATERIAL_STONE,                  // type_enum
        50,                                       // stack_int
        1,                                        // value_real
        0.5                                       // weight_real (example)
    );

    if (def_stone != undefined && ds_map_size(def_stone) > 0) { // Check if map is not empty (error case from helper)
        var _item_specific_sprite_name = "spr_stone_icon"; 
        var _item_specific_sprite_index = asset_get_index(_item_specific_sprite_name); 

        if (_item_specific_sprite_index != -1 && sprite_exists(_item_specific_sprite_index)) {
            ds_map_replace(def_stone, "sprite_asset", _item_specific_sprite_index); // Use ds_map_replace to override default
        } else {
            show_debug_message($"WARNING (scr_item_defs_materials): Sprite '{_item_specific_sprite_name}' not found for item 'stone'. Using placeholder from base.");
            // No need to add placeholder again if base_definition already set it.
        }
        global.item_defs[? "stone"] = def_stone;
    } else {
        show_debug_message("ERROR (scr_item_defs_materials): Failed to create base definition for 'stone'.");
    }

    // ============================================================================
    // Wood Definition
    // ============================================================================
    var def_wood = scr_create_item_base_definition(
        "wood",                                   // id_string
        "Wood",                                   // name_str
        "A sturdy piece of timber. Good for building and fuel.", // desc_str
        ItemType.MATERIAL_WOOD,                   // type_enum
        50,                                       // stack_int
        2,                                        // value_real
        0.8                                       // weight_real (example)
    );

    if (def_wood != undefined && ds_map_size(def_wood) > 0) {
        var _item_specific_sprite_name_wood = "spr_wood_log_icon"; 
        var _item_specific_sprite_index_wood = asset_get_index(_item_specific_sprite_name_wood);

        if (_item_specific_sprite_index_wood != -1 && sprite_exists(_item_specific_sprite_index_wood)) {
            ds_map_replace(def_wood, "sprite_asset", _item_specific_sprite_index_wood); // Override default
        } else {
            show_debug_message($"WARNING (scr_item_defs_materials): Sprite '{_item_specific_sprite_name_wood}' not found for item 'wood'. Using placeholder from base.");
        }
        global.item_defs[? "wood"] = def_wood;
    } else {
        show_debug_message("ERROR (scr_item_defs_materials): Failed to create base definition for 'wood'.");
    }
    show_debug_message("scr_item_defs_materials: Finished initializing material item definitions.");
}
#endregion


#region 2.3 scr_item_defs_equipment()
/// @function scr_item_defs_equipment()
/// @description Define equippable items (weapons, tools) and add them to global.item_defs.
function scr_item_defs_equipment() {
    show_debug_message("scr_item_defs_equipment: Initializing equipment item definitions...");
    var _placeholder_icon_exists = sprite_exists(spr_placeholder_icon);

    // --- Basic Club ---
    // You could use scr_create_item_base_definition here too!
    var def_club = scr_create_item_base_definition(
        "club_basic",                             // id_string
        "Wooden Club",                            // name_str
        "A crude wooden club for basic defense.", // desc_str
        ItemType.EQUIPMENT_WEAPON_MELEE,          // type_enum
        1,                                        // stack_int (equipment usually doesn't stack)
        5,                                        // value_real
        2.0                                       // weight_real
    );
    
    if (def_club != undefined && ds_map_size(def_club) > 0) {
        var _item_specific_sprite_name_club = "spr_club_icon";
        var _item_specific_sprite_index_club = asset_get_index(_item_specific_sprite_name_club);

        if (_item_specific_sprite_index_club != -1 && sprite_exists(_item_specific_sprite_index_club)) {
            ds_map_replace(def_club, "sprite_asset", _item_specific_sprite_index_club); // Override default
        } else {
            show_debug_message($"WARNING (scr_item_defs_equipment): Sprite '{_item_specific_sprite_name_club}' not found for item 'club_basic'. Using placeholder from base.");
        }
    
        // Add equipment-specific stats
        var stats_club = ds_map_create();
        ds_map_add(stats_club, "attack",     2);
        ds_map_add(stats_club, "durability", 20);
        ds_map_replace(def_club, "stats", stats_club); // Replace the 'undefined' stats from base
        ds_map_replace(def_club, "equip_slot", "hand"); // Example equip slot

        global.item_defs[? "club_basic"] = def_club; // Use the ID string as key
    } else {
         show_debug_message("ERROR (scr_item_defs_equipment): Failed to create base definition for 'club_basic'.");
    }
    show_debug_message("scr_item_defs_equipment: Finished initializing equipment item definitions.");
}
#endregion


//=============================================================================
// 3. QUERY FUNCTIONS
//=============================================================================

#region 3.1 scr_get_item_definition(item_id_string)
/// @function scr_get_item_definition(item_id_string)
/// @description Return the full definition ds_map for a given item_id_string, or undefined if not found.
/// @param {string} item_id_string The key of the item in global.item_defs (e.g., "berry").
/// @returns {Id.DsMap|undefined}
function scr_get_item_definition(item_id_string) {
    if (!variable_global_exists("item_defs") || 
        global.item_defs == undefined || 
        !ds_exists(global.item_defs, ds_type_map) ||
        !ds_map_exists(global.item_defs, item_id_string)) {
        // show_debug_message($"Warning (scr_get_item_definition): Item definition not found for ID: '{item_id_string}'"); // Can be noisy
        return undefined;
    }
    return global.item_defs[? item_id_string]; 
}
#endregion


#region 3.2 scr_get_item_name(item_id_string)
/// @function scr_get_item_name(item_id_string)
/// @description Return display name or empty string.
/// @param {string} item_id_string
/// @returns {string}
function scr_get_item_name(item_id_string) {
    var _def = scr_get_item_definition(item_id_string);
    if (_def == undefined) return "Unknown Item"; // More graceful fallback
    return ds_map_exists(_def, "name") ? _def[? "name"] : "Unnamed Item";
}
#endregion


#region 3.3 scr_get_item_description(item_id_string)
/// @function scr_get_item_description(item_id_string)
/// @description Return description or empty string.
/// @param {string} item_id_string
/// @returns {string}
function scr_get_item_description(item_id_string) {
    var _def = scr_get_item_definition(item_id_string);
    if (_def == undefined) return "No description available.";
    return ds_map_exists(_def, "description") ? _def[? "description"] : "No description.";
}
#endregion

#region 3.4 scr_get_item_stats(item_id_string)
/// @function scr_get_item_stats(item_id_string)
/// @description Return stats ds_map or undefined.
/// @param {string} item_id_string
/// @returns {Id.DsMap|undefined}
function scr_get_item_stats(item_id_string) {
    var _def = scr_get_item_definition(item_id_string);
    if (_def == undefined) return undefined;
    return ds_map_exists(_def, "stats") ? _def[? "stats"] : undefined;
}
#endregion

#region 3.5 scr_get_item_effects(item_id_string)
/// @function scr_get_item_effects(item_id_string)
/// @description Return effects (could be a map, array, or string) or undefined.
/// @param {string} item_id_string
/// @returns {any|undefined}
function scr_get_item_effects(item_id_string) {
    var _def = scr_get_item_definition(item_id_string);
    if (_def == undefined) return undefined;
    return ds_map_exists(_def, "effects") ? _def[? "effects"] : undefined;
}
#endregion

#region 3.6 scr_get_item_weight(item_id_string)
/// @function scr_get_item_weight(item_id_string)
/// @description Return weight or a default high value if not found (or 0, depends on desired behavior for missing weight).
/// @param {string} item_id_string
/// @returns {real}
function scr_get_item_weight(item_id_string) {
    var _def = scr_get_item_definition(item_id_string);
    if (_def == undefined) return 1; // Default weight if item unknown
    return ds_map_exists(_def, "weight") ? _def[? "weight"] : 1; // Default weight if not specified
}
#endregion

#region 3.7 scr_get_item_sprite(item_id_string)
/// @function scr_get_item_sprite(item_id_string)
/// @description Returns the sprite asset for a given item_id_string, or a placeholder sprite.
/// @param {string} item_id_string The key of the item (e.g., "berry").
/// @returns {Asset.GMSprite} Sprite asset index, or spr_placeholder_icon if not found/invalid. Returns -1 if placeholder also missing.
function scr_get_item_sprite(item_id_string) {
    var _def = scr_get_item_definition(item_id_string);
    if (_def != undefined && ds_map_exists(_def, "sprite_asset")) {
        var _sprite = _def[? "sprite_asset"];
        if (_sprite != noone && sprite_exists(_sprite)) { 
            return _sprite;
        } else {
            // Warning already handled during definition or if sprite is intentionally 'noone'
        }
    }
    if (sprite_exists(spr_placeholder_icon)) { 
        return spr_placeholder_icon;
    }
    show_debug_message($"ERROR (scr_get_item_sprite): No sprite for '{item_id_string}' AND spr_placeholder_icon is missing!");
    return -1; 
}
#endregion

#region 3.8 scr_get_item_max_stack(item_id_string)
/// @function scr_get_item_max_stack(item_id_string)
/// @description Returns the maximum stack size for an item.
/// @param {string} item_id_string
/// @returns {integer} Max stack size, or 1 if not defined/found.
function scr_get_item_max_stack(item_id_string) {
    var _def = scr_get_item_definition(item_id_string);
    if (_def == undefined) return 1; // Default stack size if item unknown
    return ds_map_exists(_def, "max_stack") ? _def[? "max_stack"] : 1; // Default stack size
}
#endregion

#region 3.9 scr_get_item_type(item_id_string)
/// @function scr_get_item_type(item_id_string)
/// @description Returns the ItemType enum for an item.
/// @param {string} item_id_string
/// @returns {enum.ItemType} ItemType, or ItemType.UNDEFINED if not found.
function scr_get_item_type(item_id_string) {
    var _def = scr_get_item_definition(item_id_string);
    if (_def == undefined || !ds_map_exists(_def, "item_type")) {
        // Ensure ItemType.UNDEFINED exists in your enum
        return (enum_exists(ItemType) && variable_struct_exists(ItemType, "UNDEFINED")) ? ItemType.UNDEFINED : -1; 
    }
    return _def[? "item_type"];
}
#endregion