/// obj_pop – Draw Event
///
/// Purpose:
///    Render the pop sprite. Displays colored name (on hover) above,
///    and state text (on hover) below. Draws selection highlight and command indicator.
///
/// Metadata:
///    Summary:         Draws pop and its UI elements, with name/state shown on hover.
///    Usage:           obj_pop Draw Event
///    Parameters:    none
///    Returns:         void
///    Tags:            [rendering][ui][pop_feedback]
///    Version:         1.19 - [Current Date] (State text now also shown only on mouse hover)
///    Dependencies:  PopState enum, PopSex enum, scr_get_state_name,
///                     fnt_pop_displayname, fnt_state, various c_ color constants,
///                     Instance variables: selected, state, image_xscale, image_yscale, x, y,
///                     is_mouse_hovering, pop_identifier_string, sex, travel_point_x, travel_point_y.

// ============================================================================
// 0. IMPORTS & CACHES
// ============================================================================
#region 0.1 Imports & Cached Locals
var _sprite_asset = sprite_index; // Current sprite asset ID
var _base_sprite_w = sprite_get_width(_sprite_asset);
var _base_sprite_h = sprite_get_height(_sprite_asset);
var _scaled_sprite_w = _base_sprite_w * image_xscale;
var _scaled_sprite_h = _base_sprite_h * image_yscale;

var _x_pop      = x; // Pop's current x position
var _y_pop      = y; // Pop's current y position
var _state_current = state; // Pop's current state enum value
var _time       = current_time; // For animations like bobbing
var _pop_sex    = variable_instance_exists(id, "sex") ? sex : undefined; // Get pop's sex if defined

// This flag now controls visibility for both name and state text when hovering
var _show_hover_details  = is_mouse_hovering; // True if mouse is over this pop (set in Step event)
#endregion


// ============================================================================
// 1. DRAW BASE SPRITE
// ============================================================================
#region 1.1 Draw Self
// GameMaker automatically uses the instance's sprite_index, image_index,
// image_xscale, image_yscale, image_angle, image_blend, image_alpha for draw_self()
draw_self();
#endregion


// ============================================================================
// 2. DRAW POP NAME (Colored by Sex, Above Pop, ONLY On Hover)
// ============================================================================
#region 2.1 Draw Pop Name
if (_show_hover_details && variable_instance_exists(id, "pop_identifier_string")) {
    var _name_text = pop_identifier_string;
    
    var _text_x = _x_pop;
    // Position text above the pop's visual center, accounting for scaled sprite height
    var _name_y_offset_from_top = 8; // Pixels above the visual top of the sprite
    var _text_y = _y_pop - (_scaled_sprite_h * 0.5) - _name_y_offset_from_top; // Assumes sprite origin is centered

    draw_set_font(fnt_pop_displayname); // Ensure fnt_pop_displayname exists
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom); // Text baseline will be at _text_y

    // Shadow for readability
    draw_set_color(c_black); // Assuming c_black is working
    draw_text(_text_x + 1, _text_y + 1, _name_text);

    // Main name text (colored by sex)
    if (_pop_sex == PopSex.MALE) {
        draw_set_color(c_orange); // Using Orange constant for Male names
    } else if (_pop_sex == PopSex.FEMALE) {
        draw_set_color(c_fuchsia); // Using Fuchsia/Pink constant for Female names
    } else {
        draw_set_color(c_white); // Default color if sex is undefined or not M/F
    }
    
    draw_text(_text_x, _text_y, _name_text);
}
#endregion


// ============================================================================
// 3. DRAW STATE TEXT (Below Pop, ONLY On Hover)
// ============================================================================
#region 3.0 Condition to Show State Text
if (_show_hover_details) { // Only draw state text if mouse is hovering
#endregion

    #region 3.1 Configure Text Style for State
    draw_set_font(fnt_state); // Ensure fnt_state exists
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);    // Text top will be at calculated _text_y_state
    #endregion

    #region 3.2 Color by State
    switch (_state_current) {
        case PopState.IDLE:     draw_set_color(c_white);    break;
        case PopState.COMMANDED: draw_set_color(c_blue);     break; 
        case PopState.FORAGING:  draw_set_color(c_lime);     break;
        case PopState.FLEEING:   draw_set_color(c_yellow);   break;
        case PopState.ATTACKING: draw_set_color(c_red);      break;
        case PopState.WANDERING: draw_set_color(c_silver);   break;
        case PopState.EATING:    draw_set_color(c_orange);   break;
        case PopState.SLEEPING:  draw_set_color(c_purple);   break;
        case PopState.WORKING:   draw_set_color(c_olive);    break;
        case PopState.CRAFTING:  draw_set_color(c_maroon);   break;
        case PopState.BUILDING:  draw_set_color(c_teal);     break;
        case PopState.HAULING:   draw_set_color(c_dkgray);   break;
        case PopState.SOCIALIZING: draw_set_color(c_fuchsia); break;
        case PopState.WAITING:   draw_set_color(c_gray);     break;
        default:                draw_set_color(c_gray);     break;
    }
    #endregion

    #region 3.3 Render State Text with Bobbing (Below Pop)
    var _offset    = sin(_time / 200) * 1; // Bobbing effect for state text
    var _state_txt = scr_get_state_name(_state_current); // Get string name of the state
    var _state_y_offset_from_bottom = 4; // Pixels below the visual bottom of the sprite
    var _text_y_state = _y_pop + (_scaled_sprite_h * 0.5) + _state_y_offset_from_bottom + _offset; // Assumes sprite origin is centered
    
    draw_text( _x_pop, _text_y_state, _state_txt );
    #endregion

#region 3.4 End Condition for State Text
} // Closing brace for 'if (_show_hover_details)'
#endregion


// ============================================================================
// 4. DRAW SELECTION HIGHLIGHT (Thicker)
// ============================================================================
#region 4.1 Selection Circle
if (selected) { // Selection circle still draws if selected, independent of hover for name/state
    draw_set_color(c_lime); 
    var _base_selection_radius_x = _base_sprite_w * 0.35;
    var _base_selection_radius_y = _base_sprite_w * 0.15;
    var _scaled_selection_radius_x = _base_selection_radius_x * image_xscale;
    var _scaled_selection_radius_y = _base_selection_radius_y * image_xscale;
    var _ellipse_center_y = _y_pop + (_scaled_sprite_h * 0.5) - _scaled_selection_radius_y; // Assumes centered origin
    var _thickness = 2; 
    for (var i = 0; i < _thickness; i++) {
        draw_ellipse(
            _x_pop - _scaled_selection_radius_x - i, _ellipse_center_y - _scaled_selection_radius_y - i,
            _x_pop + _scaled_selection_radius_x + i, _ellipse_center_y + _scaled_selection_radius_y + i,
            true); // Outline only
    }
}
#endregion


// ============================================================================
// 5. DRAW COMMAND TARGET INDICATOR
// ============================================================================
#region 5.1 Command Target Indicator
if (_state_current == PopState.COMMANDED && 
    variable_instance_exists(id, "travel_point_x") && is_real(travel_point_x) && 
    variable_instance_exists(id, "travel_point_y") && is_real(travel_point_y) && 
    (x != travel_point_x || y != travel_point_y)) { // Only draw if not yet arrived

    draw_set_alpha(0.75);
    draw_set_color(c_aqua); 
    var _marker_size = 4;
    draw_line_width(travel_point_x - _marker_size, travel_point_y - _marker_size, 
                    travel_point_x + _marker_size, travel_point_y + _marker_size, 2);
    draw_line_width(travel_point_x + _marker_size, travel_point_y - _marker_size, 
                    travel_point_x - _marker_size, travel_point_y + _marker_size, 2);
    draw_set_alpha(1.0); // Reset alpha after drawing
}
#endregion

// ============================================================================
// X. FINAL RESET (Good practice for all draw events)
// ============================================================================
#region X.1 Reset Draw Settings
draw_set_font(-1);          // Reset to default font
draw_set_color(c_white);    // Reset draw color to white
draw_set_alpha(1.0);        // Reset alpha to fully opaque
draw_set_halign(fa_left);   // Reset horizontal alignment
draw_set_valign(fa_top);    // Reset vertical alignment
#endregion