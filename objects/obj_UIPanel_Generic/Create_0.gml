/// obj_UIPanel_Generic – Create Event
/// Version:         2.4 — 2024-05-19 // Scotty's Current Date - Unified to use x, y, width, height
// ... (metadata) ...

show_debug_message($"--- obj_UIPanel_Generic (ID: {id}) - CREATE EVENT V2.4 RUNNING ---");

// ============================================================================
// 1. PANEL CONFIGURATION & DEFAULTS
// ============================================================================
#region 1.1 Core Panel Properties
panel_type              = "unknown"; 
target_data_source_id   = noone;   
panel_title             = "Panel"; 
panel_background_sprite = spr_UIborder_bone; 

// These will be set by scr_selection_controller or creation args for specific instances.
// For x and y, instance_create_layer sets them.
// For width and height, scr_selection_controller sets them directly.
// We can still have defaults if the panel is ever created without scr_selection_controller.
width                   = 350; // Default, scr_selection_controller will override
height                  = 400; // Default, scr_selection_controller will override
// x and y are set by instance_create_layer

var _panel_margin       = 26; // Local var for initial default positioning if needed
var _header_height      = 30; // Local var, or make it an instance var 'header_height' if needed by draw
header_height           = 30; // Make it an instance variable
#endregion





#region 1.2 Default Panel Position (If not set by creator)
// This default positioning is less critical now since scr_selection_controller defines it.
// var _gui_w = display_get_gui_width();
// x = _gui_w - width - _panel_margin; // Default x (instance var)
// y = _panel_margin;                 // Default y (instance var)
#endregion

#region 1.3 Dragging State
dragging                = false;
drag_offset_x           = 0;
drag_offset_y           = 0;
#endregion

#region 1.4 Close Button Properties
close_button_size       = 20; // Instance variable
close_button_margin     = 5;  // Instance variable
#endregion

// ============================================================================
// 2. INITIALIZATION FROM CREATION ARGUMENTS (Optional Struct)
// ============================================================================
#region 2.1 Process Creation Arguments
var _custom_title_provided = false;
if (variable_instance_exists(id, "panel_type_arg")) { panel_type = panel_type_arg; }
if (variable_instance_exists(id, "target_data_source_id_arg")) { target_data_source_id = target_data_source_id_arg; }
if (variable_instance_exists(id, "custom_title_arg")) { panel_title = custom_title_arg; _custom_title_provided = true;}
if (variable_instance_exists(id, "panel_background_sprite_arg")) { panel_background_sprite = panel_background_sprite_arg; }
// Note: width and height args are not processed here, scr_selection_controller sets them directly.
#endregion

show_debug_message($"Generic UI Panel Created: Type='{panel_type}', Target='{target_data_source_id}', Title='{panel_title}', BG Sprite='{sprite_get_name(panel_background_sprite)}', Initial W/H: {width}/{height}");

// ============================================================================
// 3. TYPE-SPECIFIC INITIALIZATION (Title fallback)
// ============================================================================
#region 3.1 Type-Specific Setup
if (!_custom_title_provided) {
    switch (panel_type) {
        case "pop_info": panel_title = "Information"; break;
        // ... other cases ...
    }
}
#endregion