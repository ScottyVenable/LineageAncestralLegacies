/// scr_item_definitions.gml
///
/// Purpose:
///     Centralized item-definition library. Initializes a global map of all game items
///     organized by category (consumables, materials, equipment), and provides
///     query functions to retrieve any field at runtime. Each item definition
///     now includes a 'sprite_asset' key for its inventory icon, with safe fallbacks.
///
/// Metadata:
///     Summary:        Initialize and store all item definitions, with robust sprite handling.
///     Usage:          obj_controller Create Event:   scr_item_definitions_init();
///                     Anywhere:                       scr_get_item_definition(item_id);
///                                                     scr_get_item_sprite(item_id);
///     Parameters:     item_id : string — key for the item (e.g., "berry", "stone")
///     Returns:        see each function’s docstring
///     Tags:           [data][utility][items][initialization]
///     Version:        1.2 — 2025-05-18 (Integrated safe sprite assignment with placeholder fallbacks)
///     Dependencies:   ds_map_*, sprite_exists(), asset_get_index(),
///                     spr_placeholder_icon (MUST EXIST),
///                     scr_create_item_base_definition() (MUST EXIST for materials section),
///                     ItemType enum/macros (for materials section).

//=============================================================================
// 0. GLOBAL DECLARATIONS
//=============================================================================
#region 0.1 Global Maps
// Master map: item_id (string) → definition map (which is another ds_map or struct)
global.item_defs = undefined;
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
    // If map already exists and is valid, destroy it to prevent memory leaks on re-init
    if (variable_global_exists("item_defs") && 
        global.item_defs != undefined && 
        ds_exists(global.item_defs, ds_type_map)) {
        ds_map_destroy(global.item_defs);
    }
    global.item_defs = ds_map_create();
    #endregion

    #region 1.1.2 Load Categories
    // These functions will populate global.item_defs
    // Ensure spr_placeholder_icon exists before calling these, as they rely on it.
    if (!sprite_exists(spr_placeholder_icon)) {
        show_debug_message("CRITICAL ERROR (scr_item_definitions_init): spr_placeholder_icon is MISSING. Item definitions will likely fail or lack icons.");
        // You might want to halt execution or handle this more gracefully depending on your game's needs.
    }

    scr_item_defs_consumables();
    scr_item_defs_materials(); // This will now use the version from scr_item_defs_materials_v1_1
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
    var _placeholder_icon_exists = sprite_exists(spr_placeholder_icon); // Check once

    // --- Wild Berry ---
    var def_berry = ds_map_create();
    ds_map_add(def_berry, "id",          "red_berry");
    ds_map_add(def_berry, "name",        "Wild Berry");
    ds_map_add(def_berry, "description", "A small red edible berry.");
    ds_map_add(def_berry, "weight",      0.1);
    
    // Safely assign sprite_asset for Wild Berry
    var _item_specific_sprite_name_berry = "spr_red_berry_icon";
    var _item_specific_sprite_index_berry = asset_get_index(_item_specific_sprite_name_berry);

    if (_item_specific_sprite_index_berry != -1 && sprite_exists(_item_specific_sprite_index_berry)) {
        ds_map_add(def_berry, "sprite_asset", _item_specific_sprite_index_berry);
    } else {
        show_debug_message($"WARNING (scr_item_defs_consumables): Sprite '{_item_specific_sprite_name_berry}' not found for item 'berry'.");
        if (_placeholder_icon_exists) {
            ds_map_add(def_berry, "sprite_asset", spr_placeholder_icon);
        } else {
            ds_map_add(def_berry, "sprite_asset", noone); // Fallback if even placeholder is missing
        }
    }
    
    var stats_berry = ds_map_create();
    ds_map_add(stats_berry, "hunger_restore", 2);
    ds_map_add(def_berry,   "stats",    stats_berry);
    ds_map_add(def_berry,   "effects",  undefined);
    
    ds_map_add(global.item_defs, "berry", def_berry);

    // ... Add other consumable items here, following the same pattern ...
    show_debug_message("scr_item_defs_consumables: Finished initializing consumable item definitions.");
}
#endregion


#region 2.2 scr_item_defs_materials()
/// @function scr_item_defs_materials()
/// @description Define all raw material items and add them to global.item_defs.
///              This function's content is based on scr_item_defs_materials_v1_1.
/// @dependencies scr_create_item_base_definition(), ItemType enum/macros.
function scr_item_defs_materials() {
    show_debug_message("scr_item_defs_materials: Initializing material item definitions...");

    // Ensure spr_placeholder_icon exists for fallback. This is critical.
    var _placeholder_icon_exists = sprite_exists(spr_placeholder_icon);
    if (!_placeholder_icon_exists) {
        show_debug_message("CRITICAL WARNING (scr_item_defs_materials): spr_placeholder_icon is MISSING. Placeholder system will fail.");
    }

    // ============================================================================
    // Stone Definition (Example from scr_item_defs_materials_v1_1)
    // ============================================================================
    // IMPORTANT: This assumes scr_create_item_base_definition() and ItemType.MATERIAL exist.
    var def_stone = scr_create_item_base_definition(
        "Stone",                                  // name
        "A common piece of rock. Useful for crafting.", // description
        ItemType.MATERIAL,                        // item_type (assuming ItemType.MATERIAL exists)
        50,                                       // max_stack (example)
        1,                                        // base_value (example)
        // ... any other base properties ...
    );

    if (def_stone != undefined) {
        // --- Safely assign sprite_asset for Stone ---
        var _item_specific_sprite_name = "spr_stone_icon"; // The ideal sprite name for this item
        var _item_specific_sprite_index = asset_get_index(_item_specific_sprite_name); // Try to get its ID

        if (_item_specific_sprite_index != -1 && sprite_exists(_item_specific_sprite_index)) {
            // Specific sprite exists, use it
            ds_map_add(def_stone, "sprite_asset", _item_specific_sprite_index);
            show_debug_message($"DEBUG (scr_item_defs_materials): Assigned '{_item_specific_sprite_name}' to 'stone'.");
        } else {
            // Specific sprite does NOT exist or is not a sprite
            show_debug_message($"WARNING (scr_item_defs_materials): Sprite '{_item_specific_sprite_name}' not found for item 'stone'.");
            if (_placeholder_icon_exists) {
                // Use placeholder if it exists
                ds_map_add(def_stone, "sprite_asset", spr_placeholder_icon);
                show_debug_message($"DEBUG (scr_item_defs_materials): Assigned 'spr_placeholder_icon' to 'stone'.");
            } else {
                // No specific sprite AND no placeholder sprite - store 'noone'
                ds_map_add(def_stone, "sprite_asset", noone);
                show_debug_message($"ERROR (scr_item_defs_materials): No placeholder icon available for 'stone'. Storing 'noone'.");
            }
        }
        global.item_defs[? "stone"] = def_stone;
    } else {
        show_debug_message("ERROR (scr_item_defs_materials): Failed to create base definition for 'stone'.");
    }

    // ============================================================================
    // Wood Definition (Example from scr_item_defs_materials_v1_1)
    // ============================================================================
    var def_wood = scr_create_item_base_definition(
        "Wood",
        "A sturdy piece of timber. Good for building and fuel.",
        ItemType.MATERIAL,
        50,
        2
    );

    if (def_wood != undefined) {
        var _item_specific_sprite_name_wood = "spr_wood_log_icon"; // Ideal sprite name
        var _item_specific_sprite_index_wood = asset_get_index(_item_specific_sprite_name_wood);

        if (_item_specific_sprite_index_wood != -1 && sprite_exists(_item_specific_sprite_index_wood)) {
            ds_map_add(def_wood, "sprite_asset", _item_specific_sprite_index_wood);
        } else {
            show_debug_message($"WARNING (scr_item_defs_materials): Sprite '{_item_specific_sprite_name_wood}' not found for item 'wood'.");
            if (_placeholder_icon_exists) {
                ds_map_add(def_wood, "sprite_asset", spr_placeholder_icon);
            } else {
                ds_map_add(def_wood, "sprite_asset", noone);
            }
        }
        global.item_defs[? "wood"] = def_wood;
    } else {
        show_debug_message("ERROR (scr_item_defs_materials): Failed to create base definition for 'wood'.");
    }
    // ... Add other material definitions here, following the same pattern ...
    show_debug_message("scr_item_defs_materials: Finished initializing material item definitions.");
}
#endregion


#region 2.3 scr_item_defs_equipment()

/// @function scr_item_defs_equipment()
/// @description Define equippable items (weapons, tools) and add them to global.item_defs.
function scr_item_defs_equipment() {
    show_debug_message("scr_item_defs_equipment: Initializing equipment item definitions...");
    var _placeholder_icon_exists = sprite_exists(spr_placeholder_icon); // Check once

    // --- Basic Club ---
    var def_club = ds_map_create();
    ds_map_add(def_club, "id",          "club_weapon");
    ds_map_add(def_club, "name",        "Wooden Club");
    ds_map_add(def_club, "description", "A crude wooden club for basic defense.");
    ds_map_add(def_club, "weight",      2.0);
    
    // Safely assign sprite_asset for Basic Club
    var _item_specific_sprite_name_club = "spr_club_icon";
    var _item_specific_sprite_index_club = asset_get_index(_item_specific_sprite_name_club);

    if (_item_specific_sprite_index_club != -1 && sprite_exists(_item_specific_sprite_index_club)) {
        ds_map_add(def_club, "sprite_asset", _item_specific_sprite_index_club);
    } else {
        show_debug_message($"WARNING (scr_item_defs_equipment): Sprite '{_item_specific_sprite_name_club}' not found for item 'club'.");
        if (_placeholder_icon_exists) {
            ds_map_add(def_club, "sprite_asset", spr_placeholder_icon);
        } else {
            ds_map_add(def_club, "sprite_asset", noone);
        }
    }
    
    var stats_club = ds_map_create();
    ds_map_add(stats_club, "attack",     2);
    ds_map_add(stats_club, "durability", 20);
    ds_map_add(def_club,   "stats",      stats_club);
    ds_map_add(def_club,   "effects",    undefined);
    
    ds_map_add(global.item_defs, "club", def_club);

    // ... Add other equipment items here, following the same pattern ...
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
        show_debug_message($"Warning (scr_get_item_definition): Item definition not found for ID: '{item_id_string}'");
        return undefined;
    }
    return global.item_defs[? item_id_string]; // Using accessor for ds_map
}
#endregion


#region 3.2 scr_get_item_name(item_id_string)
/// @function scr_get_item_name(item_id_string)
/// @description Return display name or empty string.
/// @param {string} item_id_string
/// @returns {string}
function scr_get_item_name(item_id_string) {
    var _def = scr_get_item_definition(item_id_string);
    return (_def != undefined && ds_map_exists(_def, "name")) ? _def[? "name"] : "";
}
#endregion


#region 3.3 scr_get_item_description(item_id_string)
/// @function scr_get_item_description(item_id_string)
/// @description Return description or empty string.
/// @param {string} item_id_string
/// @returns {string}
function scr_get_item_description(item_id_string) {
    var _def = scr_get_item_definition(item_id_string);
    return (_def != undefined && ds_map_exists(_def, "description")) ? _def[? "description"] : "";
}
#endregion

#region 3.4 scr_get_item_stats(item_id_string)
/// @function scr_get_item_stats(item_id_string)
/// @description Return stats ds_map or undefined.
/// @param {string} item_id_string
/// @returns {Id.DsMap|undefined}
function scr_get_item_stats(item_id_string) {
    var _def = scr_get_item_definition(item_id_string);
    return (_def != undefined && ds_map_exists(_def, "stats")) ? _def[? "stats"] : undefined;
}
#endregion

#region 3.5 scr_get_item_effects(item_id_string)
/// @function scr_get_item_effects(item_id_string)
/// @description Return effects (could be a map, array, or string) or undefined.
/// @param {string} item_id_string
/// @returns {any|undefined}
function scr_get_item_effects(item_id_string) {
    var _def = scr_get_item_definition(item_id_string);
    return (_def != undefined && ds_map_exists(_def, "effects")) ? _def[? "effects"] : undefined;
}
#endregion

#region 3.6 scr_get_item_weight(item_id_string)
/// @function scr_get_item_weight(item_id_string)
/// @description Return weight or 0.
/// @param {string} item_id_string
/// @returns {real}
function scr_get_item_weight(item_id_string) {
    var _def = scr_get_item_definition(item_id_string);
    return (_def != undefined && ds_map_exists(_def, "weight")) ? _def[? "weight"] : 0;
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
        if (_sprite != noone && sprite_exists(_sprite)) { // Check against noone as well
            return _sprite;
        } else {
            if (_sprite != noone) { // Log only if it was supposed to be a specific sprite but wasn't found
                 show_debug_message($"Warning (scr_get_item_sprite): Sprite asset '{_sprite}' for item '{item_id_string}' does not exist or is 'noone'. Using placeholder.");
            }
        }
    }
    // Fallback: Return spr_placeholder_icon
    if (sprite_exists(spr_placeholder_icon)) { 
        return spr_placeholder_icon;
    }
    show_debug_message($"ERROR (scr_get_item_sprite): No sprite for '{item_id_string}' AND spr_placeholder_icon is missing!");
    return -1; // Absolute fallback if no placeholder sprite exists
}
#endregion
