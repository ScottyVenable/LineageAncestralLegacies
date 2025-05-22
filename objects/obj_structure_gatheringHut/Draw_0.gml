/// obj_structure_gatheringHut – Draw Event
///
/// Purpose:
///    Draws the gathering hut and, if overlays are enabled, its drop-off slot radii and claimed slots for hauling pops.
///
/// Metadata:
///    Summary:         Draws hut and visualizes drop-off slots for learning/debugging.
///    Usage:           obj_structure_gatheringHut Draw Event
///    Parameters:      none
///    Returns:         void
///    Tags:            [rendering][overlay][debug][slot_provider]
///    Version:         1.0 - 2025-05-22
///    Dependencies:    global.show_overlays, dropoff_slots

// Draw the hut sprite (default behavior)
draw_self();

// Draw overlay for drop-off slots if enabled
if (global.show_overlays) {
    draw_set_color(c_aqua);
    draw_set_alpha(0.25);
    // Draw a circle showing the hut's interaction/slot radius
    var slot_radius = 32; // Should match Create event
    draw_circle(x, y, slot_radius, false);
    draw_set_alpha(1);
    // Draw each slot and its claim status
    for (var i = 0; i < max_dropoff_slots; i++) {
        var slot = dropoff_slots[i];
        var slot_x = x + slot.rel_x;
        var slot_y = y + slot.rel_y;
        if (slot.claimed_by != noone) {
            draw_set_color(c_red);
            draw_circle(slot_x, slot_y, 6, false);
        } else {
            draw_set_color(c_lime);
            draw_circle(slot_x, slot_y, 6, false);
        }
    }
}
