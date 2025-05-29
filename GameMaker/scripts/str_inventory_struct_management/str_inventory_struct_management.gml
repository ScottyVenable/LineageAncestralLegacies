/// scr_inventory_struct_management.gml
///
/// Purpose:
///     Provides functions to manage a struct-based inventory for instances.
///     Each instance should have an 'inventory' variable initialized as an empty struct: inventory = {};
///
/// Metadata:
///     Summary:        Functions for adding, removing, querying, and drawing struct-based inventories.
///     Tags:           [inventory][data][struct][utility]
///     Version:        1.3 — 2025-05-18 (Integrated advanced draw function with placeholder icon logic)
///     Dependencies:   global.item_defs (DS Map, initialized by scr_item_definitions_init),
///                     spr_placeholder_icon (Sprite Asset),
///                     Item definition maps within global.item_defs must contain a "sprite_asset" key,
///                     relevant font assets.

// Define your actual default UI font asset name here if you want a script-level default for drawing.
// Otherwise, ensure the font is passed into scr_inventory_struct_draw.
#macro FONT_INV_DEFAULT fnt_main_ui // Example: replace fnt_main_ui with your font, or manage via draw call

// ============================================================================
// 1. CORE LOGIC FUNCTIONS
// ============================================================================

#region 1.1 scr_inventory_struct_add(item_id_string, amount)
/// @function scr_inventory_struct_add(item_id_string, amount)
/// @description Adds a specified amount of an item to the instance's inventory struct.
/// @param {string} item_id_string    The unique string identifier for the item (e.g., "berry").
/// @param {real}   amount            The quantity of the item to add (must be > 0).
/// @returns {real} The new total quantity of the item, or 0 if invalid input.

function scr_inventory_struct_add(item_id_string, amount) {
    var _pop_id_str = variable_instance_exists(id, "pop_identifier_string") ? pop_identifier_string : "Instance " + string(id);

    if (!is_string(item_id_string) || item_id_string == "") {
        show_debug_message($"ERROR ({_pop_id_str} - scr_inventory_struct_add): item_id_string must be a non-empty string.");
        return 0;
    }
    if (!is_real(amount) || amount <= 0) {
        show_debug_message($"ERROR ({_pop_id_str} - scr_inventory_struct_add): amount for '{item_id_string}' must be a positive number. Got: {amount}");
        return 0;
    }

    if (!variable_instance_exists(id, "inventory") || !is_struct(inventory)) {
        show_debug_message($"ERROR ({_pop_id_str} - scr_inventory_struct_add): Instance does not have a valid 'inventory' struct.");
        return 0; 
    }

    var _current_qty = 0;
    if (variable_struct_exists(inventory, item_id_string)) {
        _current_qty = inventory[$ item_id_string];
    }
    
    var _new_qty = _current_qty + amount;
    inventory[$ item_id_string] = _new_qty;

    // show_debug_message($"{_pop_id_str} - Inventory Add: Added {amount} of '{item_id_string}'. New total: {_new_qty}");
    return _new_qty;
}
#endregion


#region 1.2 scr_inventory_struct_remove(item_id_string, amount)
/// @function scr_inventory_struct_remove(item_id_string, amount)
/// @description Removes a specified amount of an item from the instance's inventory struct.
/// @param {string} item_id_string    The unique string identifier for the item.
/// @param {real}   amount            The quantity of the item to remove (must be > 0).
/// @returns {real} The actual amount removed, or 0 if item not found or invalid input.

function scr_inventory_struct_remove(item_id_string, amount) {
    var _pop_id_str = variable_instance_exists(id, "pop_identifier_string") ? pop_identifier_string : "Instance " + string(id);

    if (!is_string(item_id_string) || item_id_string == "") {
        show_debug_message($"ERROR ({_pop_id_str} - scr_inventory_struct_remove): item_id_string must be a non-empty string.");
        return 0;
    }
    if (!is_real(amount) || amount <= 0) {
        show_debug_message($"ERROR ({_pop_id_str} - scr_inventory_struct_remove): amount for '{item_id_string}' must be a positive number. Got: {amount}");
        return 0;
    }

    if (!variable_instance_exists(id, "inventory") || !is_struct(inventory)) {
        show_debug_message($"ERROR ({_pop_id_str} - scr_inventory_struct_remove): Instance does not have a valid 'inventory' struct.");
        return 0;
    }
    if (!variable_struct_exists(inventory, item_id_string)) {
        // show_debug_message($"{_pop_id_str} - Inventory Remove: Item '{item_id_string}' not found. Nothing removed.");
        return 0; 
    }

    var _current_qty = inventory[$ item_id_string];
    var _amount_to_remove = min(_current_qty, amount); 

    if (_amount_to_remove <= 0) return 0; 

    var _new_qty = _current_qty - _amount_to_remove;

    if (_new_qty > 0) {
        inventory[$ item_id_string] = _new_qty;
    } else {
        struct_remove(inventory, item_id_string); 
    }
    
    // show_debug_message($"{_pop_id_str} - Inventory Remove: Removed {_amount_to_remove} of '{item_id_string}'. Remaining: {_new_qty}");
    return _amount_to_remove;
}
#endregion


#region 1.3 scr_inventory_struct_get_qty(item_id_string)
/// @function scr_inventory_struct_get_qty(item_id_string)
/// @description Gets the current quantity of a specified item in the instance's inventory.
/// @param {string} item_id_string    The unique string identifier for the item.
/// @returns {real} The quantity of the item, or 0 if not found or inventory invalid.

function scr_inventory_struct_get_qty(item_id_string) {
    if (!is_string(item_id_string) || item_id_string == "") {
        return 0;
    }
    if (!variable_instance_exists(id, "inventory") || !is_struct(inventory)) {
        return 0;
    }
    if (variable_struct_exists(inventory, item_id_string)) {
        return inventory[$ item_id_string];
    }
    return 0; 
}
#endregion


#region 1.4 scr_inventory_struct_has(item_id_string)
/// @function scr_inventory_struct_has(item_id_string)
/// @description Checks if the instance's inventory contains at least one of the specified item.
/// @param {string} item_id_string    The unique string identifier for the item.
/// @returns {bool} True if the item exists with quantity > 0, false otherwise.

function scr_inventory_struct_has(item_id_string) {
    return (scr_inventory_struct_get_qty(item_id_string) > 0);
}
#endregion

// ============================================================================
// 2. DRAWING FUNCTION
// ============================================================================

#region 2.1 scr_inventory_struct_draw(draw_x, draw_y, icon_size, line_height, text_font, text_color, [columns=1], [icon_padding=4])
/// @function scr_inventory_struct_draw(draw_x, draw_y, icon_size, line_height, text_font, text_color, [columns=1], [icon_padding=4])
/// @description Draws the contents of the calling instance's 'inventory' struct
///              at the specified GUI coordinates. Displays item icons and quantities.
///              Uses a placeholder sprite (spr_placeholder_icon) if an item's defined
///              sprite is missing or invalid.
/// @param {real}   draw_x          The starting X position in the GUI layer to draw the inventory.
/// @param {real}   draw_y          The starting Y position in the GUI layer to draw the inventory.
/// @param {real}   icon_size       The desired width and height for drawing item icons (e.g., 32).
/// @param {real}   line_height     The vertical space allocated for each item entry.
/// @param {asset.GMFont} text_font The font to use for drawing item quantities. (Can use FONT_INV_DEFAULT as default if not provided or invalid)
/// @param {c_colour} text_color    The color for the item quantity text.
/// @param {real}   [columns=1]     (Optional) Number of columns to display items in. Defaults to 1.
/// @param {real}   [icon_padding=4](Optional) Padding around icons and between icon and text. Defaults to 4.
/// @returns {real} The total height occupied by the drawn inventory.

function scr_inventory_struct_draw(_draw_x, _draw_y, _icon_size, _line_h, _font = FONT_INV_DEFAULT, _color = c_white, _columns = 1, _padding = 4) {

    // --- 0. PRE-CHECKS & INITIALIZATION ---
    var _instance_context_id_str = variable_instance_exists(id, "pop_identifier_string") ? pop_identifier_string : (object_get_name(object_index) + ":" + string(id));

    if (!variable_instance_exists(id, "inventory")) {
        show_debug_message($"ERROR ({_instance_context_id_str} - scr_inventory_struct_draw): 'inventory' struct not found on calling instance.");
        return 0;
    }
    if (!is_struct(inventory)) {
        show_debug_message($"ERROR ({_instance_context_id_str} - scr_inventory_struct_draw): 'inventory' is not a struct.");
        return 0;
    }

    if (!variable_global_exists("item_defs") || !ds_exists(global.item_defs, ds_type_map)) {
        show_debug_message($"ERROR ({_instance_context_id_str} - scr_inventory_struct_draw): global.item_defs is not initialized or not a ds_map. Call scr_item_definitions_init() at game start.");
        return 0;
    }
    
    var _placeholder_sprite_exists = sprite_exists(spr_placeholder_icon);
    if (!_placeholder_sprite_exists) {
        show_debug_message($"WARNING (scr_inventory_struct_draw): spr_placeholder_icon does not exist. Items without sprites may not display an icon.");
    }
    
    // Font validation
    var _font_to_use = FONT_INV_DEFAULT;
    if (font_exists(_font)) {
        _font_to_use = _font;
    } else if (!font_exists(FONT_INV_DEFAULT)) {
         show_debug_message($"ERROR ({_instance_context_id_str} - scr_inventory_struct_draw): Font '{_font}' or default FONT_INV_DEFAULT ('{FONT_INV_DEFAULT}') not found. Drawing may use GM default.");
    }


    // --- 0.2 Setup Drawing Variables ---
    var _item_names = variable_struct_get_names(inventory);
    var _num_items = array_length(_item_names);
    if (_num_items == 0) {
        // Optionally draw "(Empty)" text if you want
        // draw_set_font(_font_to_use);
        // draw_set_color(c_dkgray); // A muted color for empty text
        // draw_set_halign(fa_left);
        // draw_set_valign(fa_top);
        // draw_text(_draw_x, _draw_y, "(Empty)");
        // return _line_h; // Return height of one line if you draw "Empty"
        return 0; // No items, no height occupied
    }

    // Store original draw settings to restore them later
    var _original_font = draw_get_font();
    var _original_color = draw_get_color();
    var _original_halign = draw_get_halign();
    var _original_valign = draw_get_valign();

    draw_set_font(_font_to_use);
    draw_set_color(_color);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle); // Align quantity text to the middle of the line_height

    var _current_x = _draw_x;
    var _current_y = _draw_y;
    var _start_x = _draw_x;
    // Calculate column width: icon + padding on both sides + text width (approx "x999" for 3-digit numbers)
    var _col_width = (_icon_size + _padding * 2 + string_width_ext("x999", -1, -1)); 
    var _items_in_current_row = 0;
    var _max_y_drawn = _draw_y; // Tracks the lowest point drawn to calculate total height

    // --- 1. DRAW INVENTORY ITEMS ---
    for (var i = 0; i < _num_items; i++) {
        var _item_name_key = _item_names[i];
        var _item_qty = variable_struct_get(inventory, _item_name_key);

        if (!is_real(_item_qty) || _item_qty <= 0) continue; // Skip items with invalid or zero quantity

        var _item_sprite_to_draw = noone;
        
        // Attempt to get item definition from global.item_defs
        // This assumes item definitions are structs or ds_maps directly under the item name key
        var _item_def = ds_map_find_value(global.item_defs, _item_name_key);

        if (_item_def != undefined) { // Check if definition exists
            var _sprite_asset_from_def = noone;
            if (is_struct(_item_def) && variable_struct_exists(_item_def, "sprite_asset")) {
                _sprite_asset_from_def = _item_def.sprite_asset;
            } else if (ds_exists(_item_def, ds_type_map) && ds_map_exists(_item_def, "sprite_asset")) { // For older ds_map based defs
                _sprite_asset_from_def = ds_map_find_value(_item_def, "sprite_asset");
            }

            if (_sprite_asset_from_def != noone && sprite_exists(_sprite_asset_from_def)) {
                _item_sprite_to_draw = _sprite_asset_from_def;
            }
        } else {
            show_debug_message($"WARNING ({_instance_context_id_str} - scr_inventory_struct_draw): No item definition found for '{_item_name_key}' in global.item_defs.");
        }

        // If no valid specific sprite found, try to use the placeholder
        if (_item_sprite_to_draw == noone) {
            if (_placeholder_sprite_exists) {
                _item_sprite_to_draw = spr_placeholder_icon;
            } else {
                // Optional: Draw a colored square as a last resort if even placeholder is missing
                // This helps visualize that an item is there but has no icon at all.
                // draw_set_color(c_fuchsia); 
                // draw_rectangle(_current_x + _padding, _current_y + (_line_h - _icon_size)/2, _current_x + _padding + _icon_size, _current_y + (_line_h - _icon_size)/2 + _icon_size, false);
                // draw_set_color(_color); // Reset color
            }
        }

        // --- Draw Icon ---
        if (_item_sprite_to_draw != noone && sprite_exists(_item_sprite_to_draw)) {
            var _icon_draw_x = _current_x + _padding;
            // Center icon vertically within the allocated line_height
            var _icon_draw_y = _current_y + (_line_h / 2); 
            
            var _spr_w = sprite_get_width(_item_sprite_to_draw);
            var _spr_h = sprite_get_height(_item_sprite_to_draw);
            var _scale = 1.0;

            if (_spr_w > 0 && _spr_h > 0) { // Avoid division by zero if sprite has no dimensions
                var _scale_x = _icon_size / _spr_w;
                var _scale_y = _icon_size / _spr_h;
                _scale = min(_scale_x, _scale_y); // Maintain aspect ratio, fit within _icon_size box
            }
            
            // Draw sprite centered in its allocated _icon_size space
            draw_sprite_ext(
                _item_sprite_to_draw, 0,                                 // sprite, subimg
                _icon_draw_x + (_icon_size / 2), _icon_draw_y,           // x, y (draw from center of allocated icon space)
                _scale, _scale,                                          // xscale, yscale
                0, c_white, 1                                            // rot, colour, alpha
            );
        }

        // --- Draw Quantity Text ---
        var _text_x = _current_x + _icon_size + _padding * 2;
        var _text_y = _current_y + (_line_h / 2); // Vertically centered with icon
        draw_text(_text_x, _text_y, $"x{_item_qty}");
        
        _max_y_drawn = max(_max_y_drawn, _current_y + _line_h);
        _items_in_current_row++;

        // --- Advance to next column or row ---
        if (_columns > 1 && _items_in_current_row < _columns) {
            _current_x += _col_width; // Move to next column position
        } else {
            _current_x = _start_x;    // Reset to first column
            _current_y += _line_h;    // Move to next line
            _items_in_current_row = 0;
        }
    }

    // --- 2. CLEANUP & RETURN ---
    // Restore original draw settings
    draw_set_font(_original_font);
    draw_set_color(_original_color);
    draw_set_halign(_original_halign);
    draw_set_valign(_original_valign);
    
    return (_max_y_drawn - _draw_y); // Return the total height taken up by the inventory display
}
#endregion
