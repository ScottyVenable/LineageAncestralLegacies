/// scr_create_item_base_definition.gml
///
/// Purpose:
///   Creates a standardized struct for an item's base definition.
///   This struct is used to store core properties of an item, which can then
///   be stored in a global data structure (e.g., a ds_map or struct) for easy access.
///
/// Metadata:
///   Summary:       Creates and returns a base item definition struct.
///   Usage:         Called by item definition scripts (e.g., scr_item_defs_materials, scr_item_defs_tools).
///                  Typically during game initialization (e.g., in obj_controller Create Event).
///   Parameters:
///     _item_id        : real        — Unique numerical identifier for the item (e.g., 10001).
///     _name           : string      — Display name of the item (e.g., "Stone", "Raw Meat").
///     _description    : string      — (Optional) Short description for UI tooltips. Defaults to an empty string.
///     _sprite_index   : Id.Sprite   — Sprite asset used for the item's icon (e.g., spr_item_stone, spr_item_berry). Use `noone` if no specific sprite.
///     _max_stack      : real        — Maximum number of this item that can be stacked in one inventory slot (e.g., 50, 99). Must be >= 1.
///     _item_type      : real        — Enum/Constant defining the item's category (e.g., global.ITEM_TYPE_MATERIAL, global.ITEM_TYPE_FOOD).
///     _tags           : array       — (Optional) Array of strings or enums for additional categorization (e.g., ["crafting", "heavy", "edible"]). Defaults to an empty array.
///
///   Returns:       Struct — A struct containing the item's base properties, or `undefined` on validation error.
///                  Example returned struct:
///                  {
///                      id: 10001,
///                      name: "Stone",
///                      description: "A common piece of rock, useful for crafting.",
///                      sprite_index: spr_item_stone,
///                      max_stack: 50,
///                      item_type: global.ITEM_TYPE_MATERIAL,
///                      tags: ["crafting_material", "building_material"]
///                  }
///   Tags:          [data][utility][item][core]
///   Version:       1.0 — 2025-05-19 (Adjust to your current date)
///   Dependencies:  Assumes ITEM_TYPE enums/macros exist (e.g., defined in a script like scr_game_enums or obj_controller Create).
///                  Assumes sprite assets (e.g., spr_item_stone) exist or `noone` is used.

function scr_create_item_base_definition(
    _item_id,
    _name,
    _description = "",       // Optional: defaults to empty string
    _sprite_index,
    _max_stack,
    _item_type,
    _tags = []               // Optional: defaults to empty array
) {
    // =========================================================================
    // 0. IMPORTS & CACHES (Not strictly needed for this data script)
    // =========================================================================
    #region 0.1 Imports & Cached Locals
    // No specific imports needed for this function.
    #endregion

    // =========================================================================
    // 1. VALIDATION & EARLY RETURNS
    // =========================================================================
    #region 1.1 Parameter Validation
    var _error_prefix = "ERROR: scr_create_item_base_definition — ";

    if (!is_real(_item_id)) {
        show_debug_message(_error_prefix + "Invalid _item_id (must be a real number). Value: " + string(_item_id));
        return undefined;
    }
    if (!is_string(_name)) {
        show_debug_message(_error_prefix + "Invalid _name (must be a string). Item ID: " + string(_item_id) + ", Value provided: " + string(_name));
        // Regarding your error: scr_create_item_base_definition(100042, -2147483648)
        // If only two arguments were passed to this function, -2147483648 might have been passed as _name.
        // This function expects _name to be a string. Please check the calling code.
        return undefined;
    }
    if (!is_string(_description)) {
        show_debug_message(_error_prefix + "Invalid _description (must be a string). Item ID: " + string(_item_id));
        return undefined;
    }
    // sprite_index can be a sprite asset (which is a real) or 'noone' (which is -4)
    if (!is_real(_sprite_index) && _sprite_index != noone) {
        show_debug_message(_error_prefix + "Invalid _sprite_index (must be a sprite asset or 'noone'). Item ID: " + string(_item_id) + ", Value: " + string(_sprite_index));
        return undefined;
    }
    if (!is_real(_max_stack) || _max_stack < 1) {
        show_debug_message(_error_prefix + "Invalid _max_stack (must be a real number >= 1). Item ID: " + string(_item_id) + ", Value: " + string(_max_stack));
        return undefined;
    }
    if (!is_real(_item_type)) { // Assuming item types are numbers (e.g., from an enum or macro)
        show_debug_message(_error_prefix + "Invalid _item_type (must be a real number, likely an enum/macro). Item ID: " + string(_item_id) + ", Value: " + string(_item_type));
        return undefined;
    }
    if (!is_array(_tags)) {
        show_debug_message(_error_prefix + "Invalid _tags (must be an array). Item ID: " + string(_item_id));
        return undefined;
    }
    #endregion

    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS (Not strictly needed for this data script)
    // =========================================================================
    #region 2.1 Local Constants
    // No local constants specific to this function's logic.
    #endregion

    // =========================================================================
    // 3. INITIALIZATION & STATE SETUP (Not applicable here for a data constructor)
    // =========================================================================

    // =========================================================================
    // 4. CORE LOGIC
    // =========================================================================
    #region 4.1. Create Definition Struct
    var _definition_struct = {
        id            : _item_id,
        name          : _name,
        description   : _description,
        sprite_index  : _sprite_index, // The problematic value -2147483648 would have been caught by validation if passed here.
                                     // If it represented 'no sprite', pass 'noone' instead.
        max_stack     : _max_stack,
        item_type     : _item_type,
        tags          : _tags,

        // You can add more common base properties here if needed later, for example:
        // value         : 0,       // Base monetary or utility value if you add currency/trading
        // rarity        : 0,       // E.g., global.RARITY_COMMON, global.RARITY_RARE
        // is_stackable  : (_max_stack > 1), // A derived helper property
        // craft_recipe  : undefined, // To be filled by another system if it's craftable
        // equip_slot    : undefined, // If it's equippable
    };
    #endregion

    // =========================================================================
    // 5. CLEANUP & RETURN
    // =========================================================================
    #region 5.1 Cleanup & Return
    return _definition_struct;
    #endregion

    // =========================================================================
    // 6. DEBUG/PROFILING (Optional)
    // =========================================================================
    #region 6.1 Debug & Profile Hooks
    // #macro GM_MODE_DEBUG true // or use a global variable
    // if (GM_MODE_DEBUG) {
    //     show_debug_message("Item Def Created: ID=" + string(_item_id) + ", Name='" + _name + "'");
    // }
    #endregion
}