/// obj_controller – Draw Event
///
/// Purpose:
///    Handles drawing of world-space elements managed by the controller,
///    such as a real-time preview of formation slots when Ctrl is held.
///
/// Metadata:
///    Version:         1.0 - [Current Date] (Added formation slot preview)

// =========================================================================
// 1. DRAW FORMATION PREVIEW (When Ctrl is held)
// =========================================================================
#region 1.1 Draw Formation Slot Preview
if (keyboard_check(vk_control)) { // Only draw preview if Ctrl is currently held
    var _preview_center_x_room = mouse_x;
    var _preview_center_y_room = mouse_y;
    var _selected_pop_count_for_preview = 0;
    with (obj_pop) {
        if (selected) { _selected_pop_count_for_preview++; }
    }

    if (_selected_pop_count_for_preview > 0 && global.current_formation_type != Formation.NONE) {
        var _preview_slots = scr_formation_calculate_slots(
            _preview_center_x_room, _preview_center_y_room,
            _selected_pop_count_for_preview, global.current_formation_type,
            global.formation_spacing
        );

        if (array_length(_preview_slots) > 0) {
            draw_set_alpha(0.5);
            draw_set_color(c_yellow);
            for (var i = 0; i < array_length(_preview_slots); i++) {
                var _slot = _preview_slots[i];
                draw_circle(_slot.x, _slot.y, 8, true); // Draw at world coordinates (radius 8)
            }
            draw_set_alpha(1.0);
            draw_set_color(c_white); // Reset color
        }
    }
}
#endregion