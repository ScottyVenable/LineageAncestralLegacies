// obj_gui_controller - Draw GUI Event
//
// Purpose:
//   Draws all active floating dropoff texts (e.g., food deposit popups) above pops.
//   Each popup shows a sprite (e.g., food icon) and a "+X" amount, floating and fading out.
//
// Educational Note:
//   - This draws in the Draw GUI event so the text appears above all world objects.
//   - Uses the global.floating_dropoff_texts list, updated in Step.
//   - Coordinates are in room space; use camera/GUI conversion if needed.
//
// Project Convention:
//   - UI icons should use the correct sprite (e.g., spr_ui_icons_food).
//   - Font and color can be customized for clarity.

if (variable_global_exists("floating_dropoff_texts")) {
    var len = array_length(global.floating_dropoff_texts);
    for (var i = 0; i < len; i++) {
        var popup = global.floating_dropoff_texts[i];
        // --- Find the nearest obj_structure_gatheringHut to the popup's x/y ---
        var hut_id = noone;
        var min_dist = 1e9;
        with (obj_structure_gatheringHut) {
            var dist = point_distance(popup.x, popup.y, x, y);
            if (dist < min_dist) {
                min_dist = dist;
                hut_id = id;
            }
        }
        var draw_x = popup.x;
        var draw_y = popup.y;
        if (hut_id != noone) {
            // Draw above the hut (adjust Y offset for visual clarity)
            draw_x = hut_id.x;
            draw_y = hut_id.y - 48; // 48 pixels above hut center (tweak as needed)
        }
        // Set alpha for fade effect
        draw_set_alpha(popup.alpha);
        // Draw the icon sprite (if provided)
        if (popup.sprite != -1) {
            draw_sprite(popup.sprite, 0, draw_x, draw_y);
        }
        // Draw the "+X" text next to the icon
        draw_set_color(c_white);
        draw_set_font(fnt_ui_stock_count); // Use a clear UI font
        draw_text(draw_x + 20, draw_y, "+" + string(popup.amount));
        draw_set_alpha(1);
    }
}
