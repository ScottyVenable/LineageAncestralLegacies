/// obj_top_status_bar - Draw GUI Event
///
/// Purpose: Draws the top status bar with key lineage overview information.
///
/// Metadata:
///   Summary:       Renders the main game status bar.
///   Usage:         obj_top_status_bar Draw GUI Event.
///   Tags:          [ui][gui][status_bar][hud]
///   Version:       1.0 - 2024-05-19 // Scotty's Current Date
///   Dependencies:  spr_UIborder_stone (or your chosen 9-slice border sprite),
///                  fnt_main_ui (or your chosen UI font), global lineage/game variables.

// ============================================================================
// 0. BAR DIMENSIONS & APPEARANCE
// ============================================================================
#region 0.1 Bar Setup
var bar_x = 0;
var bar_y = 0; // Positioned at the very top of the GUI
var bar_width = display_get_gui_width();
var bar_height = 36; // Adjust as needed for your font size and border thickness

var border_sprite = spr_UIborder_stone; // The 9-slice sprite you set up
var text_font = fnt_main_ui;          // Your primary UI font for the status text
var text_color = c_white;
var text_padding_horizontal = 15;     // Padding from the left/right edges of the bar
var text_padding_vertical = (bar_height / 2); // To vertically center the text
var item_spacing = 70;                // Horizontal space between different status items
#endregion

// ============================================================================
// 1. DRAW BAR BACKGROUND (9-SLICE)
// ============================================================================
#region 1.1 Draw Background
if (sprite_exists(border_sprite)) {
    // Ensure 9-slice is enabled on border_sprite and "Tile Mode" is "Repeat" or "Mirror" for edges/center in Sprite Editor
    draw_sprite_ext(
        border_sprite,
        0,         // subimg
        bar_x,
        bar_y,
        bar_width / sprite_get_width(border_sprite),   // Scale X to fit bar_width
        bar_height / sprite_get_height(border_sprite), // Scale Y to fit bar_height
        0,         // angle
        c_white,   // blend
        1          // alpha
    );
} else {
    // Fallback if sprite is missing
    draw_set_color(c_dkgray);
    draw_set_alpha(0.85);
    draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);
    draw_set_alpha(1.0);
    if (!sprite_exists(border_sprite)) { // Log warning only once if sprite is consistently missing
        show_debug_message_once($"Warning (obj_top_status_bar): Sprite '{string(border_sprite)}' for top bar not found. Drawing fallback.");
    }
}
#endregion

// ============================================================================
// 2. PREPARE & DRAW STATUS TEXT
// ============================================================================
#region 2.1 Setup Text Drawing
if (font_exists(fnt_main_ui)) {
    draw_set_font(fnt_main_ui);
} else {
    // Fallback font if text_font doesn't exist (GameMaker might use a default)
    draw_set_font(-1); 
    if (!font_exists(text_font)) {
         show_debug_message_once($"Warning (obj_top_status_bar): Font '{string(text_font)}' not found. Using default.");
    }
}
draw_set_color(c_black);
draw_set_valign(fa_middle); // Vertically align text to the middle of its line
draw_set_halign(fa_left);   // Start drawing text from the left
#endregion

#region 2.2 Draw Status Items
var current_text_x = bar_x + text_padding_horizontal;
var current_text_y = bar_y + text_padding_vertical;

// --- Population ---
var pop_count = instance_number(obj_pop); // Dynamic pop count
var pop_string = $"Pops: {global.popcount} / {global.lineage_housing_capacity}";
draw_text(current_text_x, current_text_y, pop_string);
current_text_x += string_width(pop_string) + item_spacing;

// --- Food ---
var food_string = $"Food: {global.lineage_food_stock}";
draw_text(current_text_x, current_text_y, food_string);
current_text_x += string_width(food_string) + item_spacing;

// --- Wood ---
var wood_string = $"Wood: {global.lineage_wood_stock}";
draw_text(current_text_x, current_text_y, wood_string);
current_text_x += string_width(wood_string) + item_spacing;

// --- Stone ---
var stone_string = $"Stone: {global.lineage_stone_stock}";
draw_text(current_text_x, current_text_y, stone_string);
current_text_x += string_width(stone_string) + item_spacing;

// --- Day & Time (Positioned to the Right) ---
var day_time_string = $"Day: {global.game_day} ({global.game_time_display_string})";
// To draw on the right, calculate its width and subtract from bar_width
var day_time_string_width = string_width(day_time_string);
var day_time_x = bar_x + bar_width - day_time_string_width - text_padding_horizontal;
draw_text(day_time_x, current_text_y, day_time_string);

#endregion

// ============================================================================
// 3. RESET DRAW SETTINGS
// ============================================================================
#region 3.1 Reset
draw_set_valign(fa_top);  // Reset to default
draw_set_halign(fa_left); // Reset to default
draw_set_font(-1);        // Reset font
draw_set_color(c_white);  // Reset color
#endregion