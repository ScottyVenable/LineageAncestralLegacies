/// obj_pop – Draw Event
///
/// Purpose:
///    Render the pop sprite and its state overlays.
///
/// Metadata:
///    Summary:         Draw pop and conditional UI elements.  
///    Usage:           obj_pop Draw Event  
///    Parameters:    none  
///    Returns:         void  
///    Tags:            [behavior][ui]  
///    Version:         1.3 — 2025-05-18 (Old inventory drawing removed)
///    Dependencies:  draw_self(), scr_get_state_name(), variable_instance_exists()

// ============================================================================
// 0. IMPORTS & CACHES
// ============================================================================
#region 0.1 Imports & Cached Locals
var _sprite_h   = sprite_get_height(sprite_index) * image_yscale;
var _x          = x;
var _y          = y;
var _state      = state;
var _time       = current_time;
#endregion


// ============================================================================
// 1. DRAW BASE SPRITE
// ============================================================================
#region 1.1 Draw Self
draw_self();
#endregion


// ============================================================================
// 2. DRAW STATE TEXT
// ============================================================================
#region 2.1 Configure Text Style
draw_set_font(fnt_state);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
#endregion

#region 2.2 Color by State
switch (_state) {
    case PopState.IDLE:     draw_set_color(c_white);    break;
    case PopState.COMMANDED: draw_set_color(c_blue);     break;
    case PopState.FORAGING:  draw_set_color(c_lime);     break;
    case PopState.FLEEING:   draw_set_color(c_yellow);   break;
    case PopState.ATTACKING: draw_set_color(c_red);      break;
    default:                draw_set_color(c_gray);     break;
}
#endregion

#region 2.3 Render with Bobbing
var _offset    = sin(_time / 200) * 2;
var _state_txt = scr_get_state_name(_state);
draw_text(
    _x,
    _y - _sprite_h * 0.5 - 8 + _offset,
    _state_txt
);
draw_set_color(c_white);
#endregion


// ============================================================================
// 3. DRAW SELECTION HIGHLIGHT
// ============================================================================
#region 3.1 Selection Circle
if (selected) {
    draw_set_color(c_lime);
    draw_circle(
        _x,
        _y - _sprite_h * 0.5 - 4,
        5,
        false
    );
    draw_set_color(c_white);
}
#endregion


// ============================================================================
// 4. DRAW COMMAND MARKER
// ============================================================================
#region 4.1 Command Marker
if (_state == PopState.COMMANDED
 && instance_exists(position_marker)) {
    draw_set_color(c_blue);
    draw_circle(
        position_marker.x,
        position_marker.y,
        4,
        false
    );
    draw_set_color(c_white);
}
#endregion


// ============================================================================
// 5. DRAW FORAGING BERRY COUNT
// ============================================================================
#region 5.1 Forage Count
// This section might be updated later to use the new inventory system
// if you want to display a specific item count directly on the pop.
// For now, it uses 'berries_carried'. If 'berries_carried' is removed
// in favor of the new struct inventory, this will need adjustment.
if (_state == PopState.FORAGING) {
    // Assuming 'berries_carried' might be temporarily kept or you have another way to get this count.
    // If 'berries_carried' is removed, this will error or show 0.
    // We can replace this later with something like:
    // var _txt = scr_inventory_struct_get_qty("berry"); // (once that function exists)
    var _txt      = variable_instance_exists(id, "berries_carried") ? berries_carried : 0;
    var _tx       = _x;
    var _ty       = _y + _sprite_h * 0.5 + 4;

    // shadow
    draw_set_color(c_black);
    draw_set_font(fnt_ui_header);
    draw_text(_tx + 1, _ty + 1, _txt);

    // main
    draw_set_color(c_white);
    draw_text(_tx, _ty, _txt);
}
#endregion

