// Draw GUI Event for obj_temp_ui_message
draw_set_color(c_white);
draw_set_font(-1); // Use default font
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(position_x, position_y, message);

// Destroy the object after the display time has elapsed
if (current_time - creation_time >= display_time) {
    instance_destroy();
}