/// obj_UIPanel_Generic - Draw GUI Event
///
/// Purpose:
///     Draws the generic UI panel. The content drawn depends on the 'panel_type'
///     variable. For "pop_info", it displays detailed information about the
///     'target_data_source_id' (expected to be an obj_pop instance),
///     including identifier, state, position, ability scores, traits,
///     likes, dislikes, and inventory.
///
/// Metadata:
///     Summary:        Renders the UI panel with context-specific information.
///     Usage:          obj_UIPanel_Generic Draw GUI Event.
///                     Assumes 'target_data_source_id', 'panel_type', 'panel_title',
///                     'panel_background_sprite', 'x', 'y' are set.
///                     'width' and 'height' should ideally be set on creation,
///                     but this script provides defaults.
///     Parameters:     none
///     Returns:        void
///     Tags:           [ui][gui][dynamic_panel][pop_info][inventory]
///     Version:        1.1 - 2025-05-18 (Corrected width/height initialization)
///     Dependencies:   draw_sprite_stretched(), draw_set_font(), draw_set_color(), draw_text(),
///                     instance_exists(), variable_instance_exists(), scr_inventory_struct_draw(),
///                     font resources (e.g., fnt_main_ui, fnt_ui_title, fnt_ui_text, fnt_ui_small_text),
///                     sprite resources (e.g., panel_background_sprite).

// ============================================================================
// 0. PRE-CHECKS & TARGET VALIDATION (for panel_type == "pop_info")
// ============================================================================
#region 0.1 Panel Type & Target Validation
if (!variable_instance_exists(id, "panel_type") || panel_type == noone) {
    show_debug_message("DEBUG (obj_UIPanel_Generic): panel_type not set. Exiting Draw GUI.");
    exit;
}

// Panel Position
var _panel_draw_x = x; // Use the instance's x position
var _panel_draw_y = y; // Use the instance's y position

// Panel Dimensions - Safely get width and height, applying defaults if not set or invalid
var _panel_w, _panel_h;

if (variable_instance_exists(id, "width") && is_real(width) && width > 0) {
    _panel_w = width;
} else {
    _panel_w = 350; // Default width if not set or invalid
    if (!variable_instance_exists(id, "width")) {
        show_debug_message($"DEBUG (obj_UIPanel_Generic): 'width' not set on instance {id}. Using default: {_panel_w}");
    } else if (!is_real(width) || width <= 0) {
        show_debug_message($"DEBUG (obj_UIPanel_Generic): Invalid 'width' ({width}) on instance {id}. Using default: {_panel_w}");
    }
}

if (variable_instance_exists(id, "height") && is_real(height) && height > 0) {
    _panel_h = height;
} else {
    _panel_h = 500; // Default height if not set or invalid (Increased height for more info)
    if (!variable_instance_exists(id, "height")) {
        show_debug_message($"DEBUG (obj_UIPanel_Generic): 'height' not set on instance {id}. Using default: {_panel_h}");
    } else if (!is_real(height) || height <= 0) {
        show_debug_message($"DEBUG (obj_UIPanel_Generic): Invalid 'height' ({height}) on instance {id}. Using default: {_panel_h}");
    }
}


if (panel_type == "pop_info") {
    if (!variable_instance_exists(id, "target_data_source_id") ||
        target_data_source_id == noone ||
        !instance_exists(target_data_source_id)) {
        show_debug_message("DEBUG (obj_UIPanel_Generic): Target for pop_info not valid. Exiting Draw GUI.");
        exit; // Nothing to draw if target is invalid for pop_info
    }
    // Further check if the target pop has the necessary variables
    var _target_pop = target_data_source_id;
    if (!variable_instance_exists(_target_pop, "pop_identifier_string") ||
        !variable_instance_exists(_target_pop, "inventory") ||
        !variable_instance_exists(_target_pop, "ability_scores") ||
        !variable_instance_exists(_target_pop, "pop_traits") ||
        !variable_instance_exists(_target_pop, "pop_likes") ||
        !variable_instance_exists(_target_pop, "pop_dislikes") ||
        !variable_instance_exists(_target_pop, "state")) {
        show_debug_message($"Warning (obj_UIPanel_Generic): Target pop {_target_pop} is missing one or more required variables for 'pop_info' panel.");
        exit;
    }
}
#endregion

// ============================================================================
// 1. PANEL STYLING & RESOURCES
// ============================================================================
#region 1.1 Fonts & Colors
// Define fonts - replace with your actual font resources
var _fnt_title = font_exists(fnt_ui_header) ? fnt_ui_header : fnt_main_ui; // For panel title
var _fnt_header = font_exists(fnt_ui_header) ? fnt_ui_header : fnt_main_ui; // For section headers
var _fnt_text = font_exists(fnt_ui_text) ? fnt_ui_text : fnt_main_ui;     // For general text
var _fnt_item = font_exists(fnt_ui_header) ? fnt_ui_header : fnt_main_ui;             // For inventory items

var _col_text_title = c_white;
var _col_text_header = c_yellow; // Or another color to distinguish headers
var _col_text_normal = c_white;
var _col_text_value = c_ltgray; // For values next to labels
#endregion

#region 1.2 Margins & Layout
var _margin = 15; // General margin from panel edge
var _padding = 8; // Padding between elements
var _line_height_sml = 18; // Small line height for lists
var _line_height_med = 20; // Medium line height
var _line_height_lrg = 24; // Large line height for headers

var _current_y = _panel_draw_y + _margin; // Initial Y position for drawing content
var _content_x = _panel_draw_x + _margin;
var _content_width = _panel_w - (_margin * 2);
#endregion

// ============================================================================
// 2. DRAW PANEL BACKGROUND & TITLE
// ============================================================================
#region 2.1 Background Panel
// Use the panel_background_sprite instance variable
if (variable_instance_exists(id, "panel_background_sprite") && sprite_exists(panel_background_sprite)) {
    draw_sprite_stretched(panel_background_sprite, 0, _panel_draw_x, _panel_draw_y, _panel_w, _panel_h);
} else {
    // Fallback: Draw a simple rectangle if sprite is missing or not set
    draw_set_color(c_dkgray);
    draw_set_alpha(0.85);
    draw_rectangle(_panel_draw_x, _panel_draw_y, _panel_draw_x + _panel_w, _panel_draw_y + _panel_h, false);
    draw_set_alpha(1.0);
}
#endregion

#region 2.2 Panel Title
// Use the panel_title instance variable
var _title_text = "UI Panel"; // Default title
if (variable_instance_exists(id, "panel_title")) {
    _title_text = panel_title;
}

draw_set_font(_fnt_title);
draw_set_color(_col_text_title);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_text(_panel_draw_x + (_panel_w / 2), _current_y, _title_text);
_current_y += string_height_ext(_title_text, _line_height_lrg, _content_width) + _padding; // Advance Y position
#endregion

// ============================================================================
// 3. DRAW PANEL CONTENT BASED ON panel_type
// ============================================================================
draw_set_halign(fa_left); // Reset alignment for content

#region 3.1 "pop_info" Panel Content
if (panel_type == "pop_info") {
    var _pop = target_data_source_id; // Already validated

    // --- Basic Info ---
    draw_set_font(_fnt_text);
    draw_set_color(_col_text_normal);
    
    var _id_string = $"Name: {_pop.pop_identifier_string}";
    draw_text(_content_x, _current_y, _id_string);
    _current_y += string_height_ext(_id_string, _line_height_med, _content_width) + _padding;

    var _state_string = $"State: {string(_pop.state)}"; // Assuming state is an enum or string
    draw_text(_content_x, _current_y, _state_string);
    _current_y += string_height_ext(_state_string, _line_height_med, _content_width) + _padding;

    var _pos_string = $"Position: ({string_format(floor(_pop.x), 0, 0)}, {string_format(floor(_pop.y), 0, 0)})";
    draw_text(_content_x, _current_y, _pos_string);
    _current_y += string_height_ext(_pos_string, _line_height_med, _content_width) + _padding * 2; // Extra padding before next section

    // --- Ability Scores ---
    draw_set_font(_fnt_header);
    draw_set_color(_col_text_header);
    draw_text(_content_x, _current_y, "Ability Scores:");
    _current_y += string_height_ext("Ability Scores:", _line_height_med, _content_width) + (_padding / 2);
    
    draw_set_font(_fnt_text);
    draw_set_color(_col_text_value);
    var _ability_names = variable_struct_get_names(_pop.ability_scores);
    var _scores_per_line = 2; // Display 2 scores per line to save space
    var _score_line_str = "";
    for (var i = 0; i < array_length(_ability_names); i++) {
        var _name = _ability_names[i];
        var _value = variable_struct_get(_pop.ability_scores, _name);
        _score_line_str += $"{string_upper(string_char_at(_name,1))}{string_copy(_name,2,string_length(_name)-1)}: {_value}  ";
        if ((i + 1) % _scores_per_line == 0 || i == array_length(_ability_names) - 1) {
            draw_text(_content_x + _padding, _current_y, _score_line_str); // Indent values slightly
            _current_y += _line_height_sml;
            _score_line_str = "";
        }
    }
    _current_y += _padding; // Extra padding after section

    // --- Traits ---
    draw_set_font(_fnt_header);
    draw_set_color(_col_text_header);
    draw_text(_content_x, _current_y, "Traits:");
    _current_y += string_height_ext("Traits:", _line_height_med, _content_width) + (_padding / 2);

    draw_set_font(_fnt_text);
    draw_set_color(_col_text_value);
    if (array_length(_pop.pop_traits) > 0) {
        var _traits_str = "";
        for (var i = 0; i < array_length(_pop.pop_traits); i++) {
            _traits_str += _pop.pop_traits[i];
            if (i < array_length(_pop.pop_traits) - 1) {
                _traits_str += ", ";
            }
        }
        // Word wrap for traits
        draw_text_ext(_content_x + _padding, _current_y, _traits_str, _line_height_sml, _content_width - _padding);
        _current_y += string_height_ext(_traits_str, _line_height_sml, _content_width - _padding) + _padding;
    } else {
        draw_text(_content_x + _padding, _current_y, "None");
        _current_y += _line_height_sml + _padding;
    }
     _current_y += _padding;

    // --- Likes ---
    draw_set_font(_fnt_header);
    draw_set_color(_col_text_header);
    draw_text(_content_x, _current_y, "Likes:");
    _current_y += string_height_ext("Likes:", _line_height_med, _content_width) + (_padding / 2);
    
    draw_set_font(_fnt_text);
    draw_set_color(_col_text_value);
    if (array_length(_pop.pop_likes) > 0) {
        var _likes_str = "";
        for (var i = 0; i < array_length(_pop.pop_likes); i++) {
            _likes_str += _pop.pop_likes[i];
            if (i < array_length(_pop.pop_likes) - 1) {
                _likes_str += ", ";
            }
        }
        draw_text_ext(_content_x + _padding, _current_y, _likes_str, _line_height_sml, _content_width - _padding);
        _current_y += string_height_ext(_likes_str, _line_height_sml, _content_width - _padding) + _padding;
    } else {
        draw_text(_content_x + _padding, _current_y, "None");
        _current_y += _line_height_sml + _padding;
    }
    _current_y += _padding;

    // --- Dislikes ---
    draw_set_font(_fnt_header);
    draw_set_color(_col_text_header);
    draw_text(_content_x, _current_y, "Dislikes:");
    _current_y += string_height_ext("Dislikes:", _line_height_med, _content_width) + (_padding / 2);

    draw_set_font(_fnt_text);
    draw_set_color(_col_text_value);
    if (array_length(_pop.pop_dislikes) > 0) {
        var _dislikes_str = "";
        for (var i = 0; i < array_length(_pop.pop_dislikes); i++) {
            _dislikes_str += _pop.pop_dislikes[i];
            if (i < array_length(_pop.pop_dislikes) - 1) {
                _dislikes_str += ", ";
            }
        }
        draw_text_ext(_content_x + _padding, _current_y, _dislikes_str, _line_height_sml, _content_width - _padding);
        _current_y += string_height_ext(_dislikes_str, _line_height_sml, _content_width - _padding) + _padding;
    } else {
        draw_text(_content_x + _padding, _current_y, "None");
        _current_y += _line_height_sml + _padding;
    }
    _current_y += _padding * 2; // Extra padding before inventory

    // --- Inventory ---
    draw_set_font(_fnt_header);
    draw_set_color(_col_text_header);
    draw_text(_content_x, _current_y, "Inventory:");
    _current_y += string_height_ext("Inventory:", _line_height_med, _content_width) + _padding;

    // Call the struct-based inventory drawing function.
    // This function needs to be called in the context of the target pop.
    with (_pop) {
        // Parameters for scr_inventory_struct_draw: draw_x, draw_y, icon_size, line_height, font, color
        // Ensure the icon_size and line_height are appropriate for the panel.
        // The scr_inventory_struct_draw function will handle its own y-positioning internally from this starting point.
        scr_inventory_struct_draw(_content_x + _padding, _current_y, 16, 18, _fnt_item, _col_text_value);
        // Note: We don't know exactly how much vertical space scr_inventory_struct_draw will take.
        // If more content needs to be drawn *after* the inventory, this _current_y would need to be
        // updated based on the inventory's drawn height. For now, inventory is last.
    }
}
#endregion

#region 3.2 Other Panel Types (Placeholder)
// else if (panel_type == "some_other_type") {
//     // ... drawing logic for another panel type ...
// }
#endregion

// ============================================================================
// 4. CLEANUP (Reset Draw Settings)
// ============================================================================
#region 4.1 Reset Draw Settings
draw_set_halign(fa_left); // Reset to default
draw_set_valign(fa_top);  // Reset to default
if (font_exists(fnt_main_ui)) draw_set_font(fnt_main_ui); // Reset to a default game font
draw_set_color(c_white);  // Reset to default
draw_set_alpha(1.0);      // Reset alpha
#endregion
