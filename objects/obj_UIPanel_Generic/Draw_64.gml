/// obj_UIPanel_Generic - Draw GUI Event
///
/// Purpose:
///     Draws the generic UI panel. The content drawn depends on the 'panel_type'
///     variable. For "pop_info", it displays detailed information about the
///     'target_data_source_id' (expected to be an obj_pop instance).
///     Includes enhanced debugging for visibility and data validation.
///
/// Metadata:
///     Summary:        Renders the UI panel with context-specific information and debug checks.
///     Usage:          obj_UIPanel_Generic Draw GUI Event.
///     Tags:           [ui][gui][dynamic_panel][pop_info][inventory][debug]
///     Version:        1.2 - 2024-05-19 // Scotty's Current Date - Added full debugging for pop vars & types
///     Dependencies:   (Same as v1.1)

// ============================================================================
// 0. VISIBILITY CHECK & INITIAL DEBUG LOGS
// ============================================================================
#region 0.0 Visibility and Initial State Log
if (!visible) { // Check if the panel instance itself is set to be visible
    // show_debug_message($"Panel {id} Draw GUI: Instance not visible (visible = {visible}). Exiting."); // Optional: uncomment if needed
    exit; 
}

show_debug_message($"--- Panel Draw GUI (ID: {id}, Obj: {object_get_name(object_index)}) Attempting to Draw ---");

// Log critical instance variables that control drawing, if they exist
var _log_w = (variable_instance_exists(id, "width")) ? width : "Default(350)";
var _log_h = (variable_instance_exists(id, "height")) ? height : "Default(500)";
var _log_panel_type = (variable_instance_exists(id, "panel_type")) ? panel_type : "UNSET";
var _log_target = (variable_instance_exists(id, "target_data_source_id")) ? target_data_source_id : "UNSET";
var _log_title = (variable_instance_exists(id, "panel_title")) ? panel_title : "UNSET";
var _log_bg_sprite_name = "UNSET";
if (variable_instance_exists(id, "panel_background_sprite")) {
    if (sprite_exists(panel_background_sprite)) {
        _log_bg_sprite_name = $"{sprite_get_name(panel_background_sprite)} (Exists)";
    } else {
         _log_bg_sprite_name = $"ID {panel_background_sprite} (MISSING!)";
    }
}
show_debug_message($"Panel State: X: {x}, Y: {y}, W: {_log_w}, H: {_log_h}, Visible: {visible}");
show_debug_message($"Panel Config: Type: {_log_panel_type}, Title: '{_log_title}', Target: {_log_target}, BG Sprite: {_log_bg_sprite_name}");
#endregion

// ============================================================================
// 0. PRE-CHECKS & TARGET VALIDATION (for panel_type == "pop_info")
// ============================================================================
#region 0.1 Panel Type & Target Validation
if (!variable_instance_exists(id, "panel_type") || panel_type == noone || panel_type == "unknown") { // Added "unknown" check
    show_debug_message("Panel Draw: panel_type not set, 'noone', or 'unknown'. EXITING.");
    show_debug_message($"--- Panel Draw GUI (ID: {id}) FINISHED (Exited Early) ---");
    exit;
}

// Panel Position
var _panel_draw_x = x; 
var _panel_draw_y = y; 

// Panel Dimensions - Safely get width and height
var _panel_w, _panel_h;
if (variable_instance_exists(id, "width") && is_real(width) && width > 0) { _panel_w = width; } 
else { _panel_w = 350; show_debug_message($"Panel Draw: Using default width {_panel_w}. Instance 'width' was: {((variable_instance_exists(id,"width")) ? width : "NOT SET")}"); }

if (variable_instance_exists(id, "height") && is_real(height) && height > 0) { _panel_h = height; } 
else { _panel_h = 500; show_debug_message($"Panel Draw: Using default height {_panel_h}. Instance 'height' was: {((variable_instance_exists(id,"height")) ? height : "NOT SET")}"); }


if (panel_type == "pop_info") {
    if (!variable_instance_exists(id, "target_data_source_id") ||
        target_data_source_id == noone ||
        !instance_exists(target_data_source_id)) {
        show_debug_message($"Panel Draw: Pop_info target invalid (Value: {target_data_source_id}). EXITING.");
        show_debug_message($"--- Panel Draw GUI (ID: {id}) FINISHED (Exited Early) ---");
        exit; 
    }
    var _target_pop = target_data_source_id;
    show_debug_message($"Panel Draw: Pop_info target is Pop ID {_target_pop}. Checking required pop variables...");

    var _vars_ok = true;
    var _missing_var_report = "";

    // Check pop_identifier_string
    if (!variable_instance_exists(_target_pop, "pop_identifier_string")) { _vars_ok = false; _missing_var_report += "pop_identifier_string (missing),"; }
    
    // Check inventory (existence and type)
    if (!variable_instance_exists(_target_pop, "inventory")) { 
        _vars_ok = false; _missing_var_report += "inventory (missing),"; 
    } else if (!is_struct(_target_pop.inventory) && !ds_exists(_target_pop.inventory, ds_type_map)) { // Allow struct or ds_map for flexibility
        _vars_ok = false; _missing_var_report += "inventory (not a struct/ds_map!),";
    }
    
    // Check ability_scores (existence and type)
    if (!variable_instance_exists(_target_pop, "ability_scores")) { 
        _vars_ok = false; _missing_var_report += "ability_scores (missing),"; 
    } else if (!is_struct(_target_pop.ability_scores)) {
         _vars_ok = false; _missing_var_report += "ability_scores (not a struct!),";
    }
    
    // Check pop_traits (existence and type)
    if (!variable_instance_exists(_target_pop, "pop_traits")) { 
        _vars_ok = false; _missing_var_report += "pop_traits (missing),";
    } else if (!is_array(_target_pop.pop_traits)) {
        _vars_ok = false; _missing_var_report += "pop_traits (not an array!),";
    }
    
    // Check pop_likes (existence and type)
    if (!variable_instance_exists(_target_pop, "pop_likes")) { 
        _vars_ok = false; _missing_var_report += "pop_likes (missing),";
    } else if (!is_array(_target_pop.pop_likes)) {
        _vars_ok = false; _missing_var_report += "pop_likes (not an array!),";
    }

    // Check pop_dislikes (existence and type)
    if (!variable_instance_exists(_target_pop, "pop_dislikes")) { 
        _vars_ok = false; _missing_var_report += "pop_dislikes (missing),";
    } else if (!is_array(_target_pop.pop_dislikes)) {
        _vars_ok = false; _missing_var_report += "pop_dislikes (not an array!),";
    }

    // Check state
    if (!variable_instance_exists(_target_pop, "state")) { _vars_ok = false; _missing_var_report += "state (missing),"; }

    if (!_vars_ok) {
        show_debug_message($"Panel Draw: Target pop {_target_pop} has MISSING/INVALID variables: [{string_delete(_missing_var_report, string_length(_missing_var_report), 1)}]. EXITING."); // Remove trailing comma
        show_debug_message($"--- Panel Draw GUI (ID: {id}) FINISHED (Exited Early) ---");
        exit;
    }
    show_debug_message("Panel Draw: All required pop variables exist and have correct basic types. Proceeding to draw background...");
}
#endregion

// ============================================================================
// 1. PANEL STYLING & RESOURCES
// ============================================================================
#region 1.1 Fonts & Colors
var _fnt_title = font_exists(fnt_ui_header) ? fnt_ui_header : (font_exists(fnt_main_ui) ? fnt_main_ui : -1);
var _fnt_header = font_exists(fnt_ui_header) ? fnt_ui_header : (font_exists(fnt_main_ui) ? fnt_main_ui : -1);
var _fnt_text = font_exists(fnt_ui_text) ? fnt_ui_text : (font_exists(fnt_main_ui) ? fnt_main_ui : -1);
var _fnt_item = font_exists(fnt_ui_header) ? fnt_ui_header : (font_exists(fnt_main_ui) ? fnt_main_ui : -1); // fnt_ui_small_text might be better

if (_fnt_title == -1) { show_debug_message("Panel Draw WARNING: No valid title font found (fnt_ui_header or fnt_main_ui)."); }

var _col_text_title = c_white;
var _col_text_header = c_yellow; 
var _col_text_normal = c_white;
var _col_text_value = variable_global_exists("c_ltgray") ? c_ltgray : c_silver; // Fallback for c_ltgray
#endregion

#region 1.2 Margins & Layout
var _margin = 15; 
var _padding = 8; 
var _line_height_sml = (font_exists(_fnt_text) && _fnt_text != -1) ? string_height("Tj") + 4 : 18; // Dynamic based on font if possible
var _line_height_med = (font_exists(_fnt_text) && _fnt_text != -1) ? string_height("Tj") + 6 : 20;
var _line_height_lrg = (font_exists(_fnt_title) && _fnt_title != -1) ? string_height("Tj") + 8 : 24;

var _current_y = _panel_draw_y + _margin; 
var _content_x = _panel_draw_x + _margin;
var _content_width = _panel_w - (_margin * 2);
#endregion

// ============================================================================
// 2. DRAW PANEL BACKGROUND & TITLE
// ============================================================================
#region 2.1 Background Panel
if (variable_instance_exists(id, "panel_background_sprite") && sprite_exists(panel_background_sprite)) {
    draw_sprite_stretched(panel_background_sprite, 0, _panel_draw_x, _panel_draw_y, _panel_w, _panel_h);
    show_debug_message("Panel Draw: Drew background sprite.");
} else {
    draw_set_color(c_dkgray); draw_set_alpha(0.85);
    draw_rectangle(_panel_draw_x, _panel_draw_y, _panel_draw_x + _panel_w, _panel_draw_y + _panel_h, false);
    draw_set_alpha(1.0);
    show_debug_message("Panel Draw: Drew fallback background rectangle.");
}
#endregion

#region 2.2 Panel Title
var _title_text_to_draw = (variable_instance_exists(id, "panel_title")) ? panel_title : "UI Panel";
if (_fnt_title != -1) draw_set_font(_fnt_title);
draw_set_color(_col_text_title);
draw_set_halign(fa_center); draw_set_valign(fa_top);
draw_text(_panel_draw_x + (_panel_w / 2), _current_y, _title_text_to_draw);
_current_y += string_height_ext(_title_text_to_draw, _line_height_lrg, _content_width) + _padding; 
show_debug_message($"Panel Draw: Drew title '{_title_text_to_draw}'. Current Y: {_current_y}");
#endregion

// ============================================================================
// 3. DRAW PANEL CONTENT BASED ON panel_type
// ============================================================================
draw_set_halign(fa_left); 

#region 3.1 "pop_info" Panel Content
if (panel_type == "pop_info") {
    var _pop = target_data_source_id; 
    show_debug_message("Panel Draw: Starting to draw pop_info content...");

    // --- Basic Info ---
    if (_fnt_text != -1) draw_set_font(_fnt_text);
    draw_set_color(_col_text_normal);
    var _temp_y_start_basic = _current_y;
    var _id_string = $"Name: {_pop.pop_identifier_string}";
    draw_text(_content_x, _current_y, _id_string); _current_y += string_height_ext(_id_string, _line_height_med, _content_width) + _padding;
    var _state_string = $"State: {scr_get_state_name(_pop.state)}"; // Use scr_get_state_name
    draw_text(_content_x, _current_y, _state_string); _current_y += string_height_ext(_state_string, _line_height_med, _content_width) + _padding;
    var _pos_string = $"Position: ({string_format(floor(_pop.x), 0, 0)}, {string_format(floor(_pop.y), 0, 0)})";
    draw_text(_content_x, _current_y, _pos_string); _current_y += string_height_ext(_pos_string, _line_height_med, _content_width) + _padding * 2;
    show_debug_message($"Panel Draw: Drew Basic Info. Y advanced by: {_current_y - _temp_y_start_basic}");

    // --- Ability Scores ---
    if (_fnt_header != -1) draw_set_font(_fnt_header); draw_set_color(_col_text_header);
    draw_text(_content_x, _current_y, "Ability Scores:"); _current_y += string_height_ext("Ability Scores:", _line_height_med, _content_width) + (_padding / 2);
    if (_fnt_text != -1) draw_set_font(_fnt_text); draw_set_color(_col_text_value);
    var _ability_names = variable_struct_get_names(_pop.ability_scores);
    var _scores_per_line = 2; var _score_line_str = "";
    for (var i = 0; i < array_length(_ability_names); i++) { /* ... drawing scores ... */ 
        var _name = _ability_names[i]; var _value = variable_struct_get(_pop.ability_scores, _name);
        _score_line_str += $"{string_upper(string_char_at(_name,1))}{string_copy(_name,2,string_length(_name)-1)}: {_value}  ";
        if ((i + 1) % _scores_per_line == 0 || i == array_length(_ability_names) - 1) {
            draw_text(_content_x + _padding, _current_y, _score_line_str); _current_y += _line_height_sml; _score_line_str = "";
        }
    } _current_y += _padding; show_debug_message("Panel Draw: Drew Ability Scores.");

    // --- Traits ---
    if (_fnt_header != -1) draw_set_font(_fnt_header); draw_set_color(_col_text_header);
    draw_text(_content_x, _current_y, "Traits:"); _current_y += string_height_ext("Traits:", _line_height_med, _content_width) + (_padding / 2);
    if (_fnt_text != -1) draw_set_font(_fnt_text); draw_set_color(_col_text_value);
    if (array_length(_pop.pop_traits) > 0) { /* ... drawing traits ... */ 
        var _traits_str = ""; for (var i = 0; i < array_length(_pop.pop_traits); i++) { _traits_str += _pop.pop_traits[i] + ( (i < array_length(_pop.pop_traits) - 1) ? ", " : "");}
        draw_text_ext(_content_x + _padding, _current_y, _traits_str, _line_height_sml, _content_width - _padding);
        _current_y += string_height_ext(_traits_str, _line_height_sml, _content_width - _padding) + _padding;
    } else { draw_text(_content_x + _padding, _current_y, "None"); _current_y += _line_height_sml + _padding; }
     _current_y += _padding; show_debug_message("Panel Draw: Drew Traits.");

    // --- Likes ---
    if (_fnt_header != -1) draw_set_font(_fnt_header); draw_set_color(_col_text_header);
    draw_text(_content_x, _current_y, "Likes:"); _current_y += string_height_ext("Likes:", _line_height_med, _content_width) + (_padding / 2);
    if (_fnt_text != -1) draw_set_font(_fnt_text); draw_set_color(_col_text_value);
    if (array_length(_pop.pop_likes) > 0) { /* ... drawing likes ... */ 
        var _likes_str = ""; for (var i = 0; i < array_length(_pop.pop_likes); i++) { _likes_str += _pop.pop_likes[i] + ( (i < array_length(_pop.pop_likes) - 1) ? ", " : "");}
        draw_text_ext(_content_x + _padding, _current_y, _likes_str, _line_height_sml, _content_width - _padding);
        _current_y += string_height_ext(_likes_str, _line_height_sml, _content_width - _padding) + _padding;
    } else { draw_text(_content_x + _padding, _current_y, "None"); _current_y += _line_height_sml + _padding; }
    _current_y += _padding; show_debug_message("Panel Draw: Drew Likes.");

    // --- Dislikes ---
    if (_fnt_header != -1) draw_set_font(_fnt_header); draw_set_color(_col_text_header);
    draw_text(_content_x, _current_y, "Dislikes:"); _current_y += string_height_ext("Dislikes:", _line_height_med, _content_width) + (_padding / 2);
    if (_fnt_text != -1) draw_set_font(_fnt_text); draw_set_color(_col_text_value);
    if (array_length(_pop.pop_dislikes) > 0) { /* ... drawing dislikes ... */ 
        var _dislikes_str = ""; for (var i = 0; i < array_length(_pop.pop_dislikes); i++) { _dislikes_str += _pop.pop_dislikes[i] + ( (i < array_length(_pop.pop_dislikes) - 1) ? ", " : "");}
        draw_text_ext(_content_x + _padding, _current_y, _dislikes_str, _line_height_sml, _content_width - _padding);
        _current_y += string_height_ext(_dislikes_str, _line_height_sml, _content_width - _padding) + _padding;
    } else { draw_text(_content_x + _padding, _current_y, "None"); _current_y += _line_height_sml + _padding; }
    _current_y += _padding * 2; show_debug_message("Panel Draw: Drew Dislikes.");

    // --- Inventory ---
    if (_fnt_header != -1) draw_set_font(_fnt_header); draw_set_color(_col_text_header);
    draw_text(_content_x, _current_y, "Inventory:"); _current_y += string_height_ext("Inventory:", _line_height_med, _content_width) + _padding;
    
    if (script_exists(scr_inventory_struct_draw)) {
        with (_pop) { // Call in context of the pop
            // Assuming scr_inventory_struct_draw uses other. for panel's _content_x, _padding etc. if needed,
            // or simply draws relative to the x,y passed.
            var _inv_x = other._content_x + other._padding; // Pass panel's content x
            var _inv_y = other._current_y;                 // Pass panel's current y
            scr_inventory_struct_draw(_inv_x, _inv_y, 16, 18, other._fnt_item, other._col_text_value);
            // Note: _current_y is not updated here based on inventory height. Inventory is last.
        }
        show_debug_message("Panel Draw: Called scr_inventory_struct_draw.");
    } else {
        show_debug_message("Panel Draw WARNING: scr_inventory_struct_draw script does not exist! Cannot draw inventory.");
        draw_text(_content_x + _padding, _current_y, "[Inventory System Placeholder]");
         _current_y += _line_height_med;
    }
    show_debug_message("Panel Draw: Finished drawing pop_info content.");
}
#endregion

#region 3.2 Other Panel Types (Placeholder)
// else if (panel_type == "some_other_type") { /* ... */ }
#endregion

// ============================================================================
// 4. CLEANUP (Reset Draw Settings)
// ============================================================================
#region 4.1 Reset Draw Settings
draw_set_halign(fa_left); 
draw_set_valign(fa_top);  
if (font_exists(fnt_main_ui) && fnt_main_ui != -1) draw_set_font(fnt_main_ui); else draw_set_font(-1);
draw_set_color(c_white);  
draw_set_alpha(1.0);      
#endregion

show_debug_message($"--- Panel Draw GUI (ID: {id}, Obj: {object_get_name(object_index)}) FINISHED ---");