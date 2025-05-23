/// obj_redBerryBush – Draw Event

// 1) Draw the bush as usual
draw_self();

// 2) Compute the bar geometry
var bar_w      = 32;                         // total width of the bar
var bar_h      = 4;                          // height in pixels
var padding    = 2;                          // gap from sprite bottom
var sprite_h   = sprite_get_height(sprite_index) * image_yscale;
var bar_x      = x - bar_w * 0.5;            // center under bush
var bar_y      = y - sprite_h * 0.5 + sprite_h + padding;

// 3) Draw background (empty) bar
draw_set_color(make_color_rgb(60, 60, 60));  // dark gray
draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, false);

// 4) Draw filled portion
// Use resource_count instead of berry_count
var fill_pct = clamp(resource_count / max_berries, 0, 1); 
var fill_w   = bar_w * fill_pct;
draw_set_color(make_color_rgb(100, 200, 100));  // green
draw_rectangle(bar_x, bar_y, bar_x + fill_w, bar_y + bar_h, false);

// 5) Optional: draw a thin border around the bar
draw_set_color(c_black);
draw_rectangle(bar_x, bar_y, bar_x + bar_w, bar_y + bar_h, true);

// 6) Reset draw color
draw_set_color(c_white);
