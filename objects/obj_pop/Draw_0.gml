/// obj_pop – Draw Event
///
/// Purpose:
///    Render the pop sprite. Displays colored name (on hover/selection) above, state text below.
///    Uses c_ constants for name colors as a workaround for make_rgb issue.
///
/// Metadata:
///    Version:         1.15 - [Current Date] (Using c_ constants for name colors)
///    Dependencies:  ... PopSex enum (from scr_constants), fnt_pop_displayname ...

// ============================================================================
// 0. IMPORTS & CACHES
// ============================================================================
#region 0.1 Imports & Cached Locals
var _sprite_asset = sprite_index;
var _base_sprite_w = sprite_get_width(_sprite_asset);
var _base_sprite_h = sprite_get_height(_sprite_asset);
var _scaled_sprite_w = _base_sprite_w * image_xscale;
var _scaled_sprite_h = _base_sprite_h * image_yscale;

var _x_pop      = x;
var _y_pop      = y;
var _state_current = state;
var _time       = current_time;
var _pop_sex    = variable_instance_exists(id, "sex") ? sex : undefined;
var _show_name  = (is_mouse_hovering || (selected && is_solely_selected)); // New condition
#endregion


// ============================================================================
// 1. DRAW BASE SPRITE
// ============================================================================
#region 1.1 Draw Self
draw_self();
#endregion


// ============================================================================
// 2. DRAW POP NAME (Colored by Sex, Above Pop, On Hover or if Selected)
// ============================================================================
#region 2.1 Draw Pop Name
if (_show_name && variable_instance_exists(id, "pop_identifier_string")) {
    var _name_text = pop_identifier_string;
    
    var _text_x = _x_pop;
    var _name_y_offset_from_top = 8;
    var _text_y = _y_pop - (_scaled_sprite_h * 0.5) - _name_y_offset_from_top;

    draw_set_font(fnt_pop_displayname);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);

    // Shadow for readability (always black)
    draw_set_color(c_black);
    draw_text(_text_x + 1, _text_y + 1, _name_text);

    // Main name text (colored using c_ constants)
    if (_pop_sex == PopSex.MALE) {
        draw_set_color(c_orange); // Using Light Blue constant
    } else if (_pop_sex == PopSex.FEMALE) {
        draw_set_color(c_fuchsia); // Using Fuchsia/Pink constant
    } else {
        draw_set_color(c_white); // Default color
    }
    
    draw_text(_text_x, _text_y, _name_text);
}
#endregion


// ============================================================================
// 3. DRAW STATE TEXT (Below Pop)
// ============================================================================
#region 3.1 Configure Text Style for State
draw_set_font(fnt_state);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
#endregion

#region 3.2 Color by State
switch (_state_current) {
    case PopState.IDLE:     draw_set_color(c_white);    break;
    case PopState.COMMANDED: draw_set_color(c_blue);     break; // Using c_blue, distinct from c_ltblue for name
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
    case PopState.SOCIALIZING: draw_set_color(c_fuchsia); break; // Female name is also fuchsia, consider if this is an issue
    case PopState.WAITING:   draw_set_color(c_gray);     break;
    default:                draw_set_color(c_gray);     break;
}
#endregion

#region 3.3 Render State Text with Bobbing (Below Pop)
var _offset    = sin(_time / 200) * 1;
var _state_txt = scr_get_state_name(_state_current);
var _state_y_offset_from_bottom = 4;
var _text_y_state = _y_pop + (_scaled_sprite_h * 0.5) + _state_y_offset_from_bottom + _offset;
draw_text( _x_pop, _text_y_state, _state_txt );
#endregion


// ============================================================================
// 4. DRAW SELECTION HIGHLIGHT (Thicker)
// ============================================================================
#region 4.1 Selection Circle
if (selected) {
    draw_set_color(c_lime);
    var _base_selection_radius_x = _base_sprite_w * 0.35;
    var _base_selection_radius_y = _base_sprite_w * 0.15;
    var _scaled_selection_radius_x = _base_selection_radius_x * image_xscale;
    var _scaled_selection_radius_y = _base_selection_radius_y * image_xscale;
    var _ellipse_center_y = _y_pop + (_scaled_sprite_h * 0.5) - _scaled_selection_radius_y;
    var _thickness = 2; 
    for (var i = 0; i < _thickness; i++) {
        draw_ellipse(
            _x_pop - _scaled_selection_radius_x - i, _ellipse_center_y - _scaled_selection_radius_y - i,
            _x_pop + _scaled_selection_radius_x + i, _ellipse_center_y + _scaled_selection_radius_y + i,
            true);
    }
}
#endregion


// ============================================================================
// 5. DRAW COMMAND TARGET INDICATOR
// ============================================================================
#region 5.1 Command Target Indicator
if (_state_current == PopState.COMMANDED && variable_instance_exists(id, "travel_point_x") && is_real(travel_point_x) && variable_instance_exists(id, "travel_point_y") && is_real(travel_point_y) && (x != travel_point_x || y != travel_point_y)) {
    draw_set_alpha(0.75);
    draw_set_color(c_aqua);
    var _marker_size = 4;
    draw_line_width(travel_point_x - _marker_size, travel_point_y - _marker_size, travel_point_x + _marker_size, travel_point_y + _marker_size, 2);
    draw_line_width(travel_point_x + _marker_size, travel_point_y - _marker_size, travel_point_x - _marker_size, travel_point_y + _marker_size, 2);
    draw_set_alpha(1.0);
}
#endregion

// ============================================================================
// X. FINAL RESET (Good practice)
// ============================================================================
#region X.1 Reset Draw Settings
draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1.0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
#endregion