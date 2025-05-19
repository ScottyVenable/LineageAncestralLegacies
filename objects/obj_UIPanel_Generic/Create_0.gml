/// obj_UIPanel_Generic – Create Event
///
/// Purpose:
///    Initializes variables for a generic UI panel, including its type,
///    position, dragging state, content-specific data, and background sprite.
///    Argument variables passed via struct on creation are expected to be auto-cleaned.
///
/// Metadata:
///    Summary:         Sets up the initial state for a configurable UI panel.
///    Usage:           obj_UIPanel_Generic Create Event.
///                     When creating an instance, set 'panel_type_arg', 'target_data_source_id_arg', etc.
///                     in an instance_create_layer call using a struct.
///    Parameters:    (optional struct passed during instance creation)
///    Returns:         void
///    Tags:            [ui][generic][panel][init]
///    Version:         2.3 — 2025-05-18 (Commented out explicit variable_instance_remove calls)
///    Dependencies:  display_get_gui_width()

// ============================================================================
// 1. PANEL CONFIGURATION & DEFAULTS
// ============================================================================
#region 1.1 Core Panel Properties
panel_type              = "unknown"; 
target_data_source_id   = noone;   
panel_title             = "Panel"; 
panel_background_sprite = spr_UIborder_bone; // Default background sprite

panel_width             = 350;
panel_height            = 400;
panel_margin            = 26;
header_height           = 30;
#endregion

#region 1.2 Panel Position
var _gui_w = display_get_gui_width();
panel_x = _gui_w - panel_width - panel_margin; 
panel_y = panel_margin;
#endregion

#region 1.3 Dragging State
dragging                = false;
drag_offset_x           = 0;
drag_offset_y           = 0;
#endregion

#region 1.4 Close Button
close_button_size       = 20;
close_button_margin     = 5;
#endregion

// ============================================================================
// 2. INITIALIZATION FROM CREATION ARGUMENTS (Optional Struct)
// ============================================================================
#region 2.1 Process Creation Arguments
// Flags to track if arguments were processed, for more precise default setting later if needed.
var _custom_title_provided = false;

if (variable_instance_exists(id, "panel_type_arg")) {
    panel_type = panel_type_arg;
}
if (variable_instance_exists(id, "target_data_source_id_arg")) {
    target_data_source_id = target_data_source_id_arg;
}
if (variable_instance_exists(id, "custom_title_arg")) {
    panel_title = custom_title_arg;
    _custom_title_provided = true;
}
if (variable_instance_exists(id, "panel_background_sprite_arg")) { 
    panel_background_sprite = panel_background_sprite_arg;
}
// Add more overridable properties here...

// Clean up argument variables (GMS 2.3+)
// According to documentation, these temporary variables should be removed automatically
// after the Create Event. Explicitly calling variable_instance_remove was causing an error.
// We are now relying on the automatic cleanup.

// if (variable_instance_exists(id, "panel_type_arg")) {
//     // variable_instance_remove(id, "panel_type_arg"); // Caused error, relying on auto-cleanup
// }
// if (variable_instance_exists(id, "target_data_source_id_arg")) {
//     // variable_instance_remove(id, "target_data_source_id_arg"); // Caused error
// }
// if (variable_instance_exists(id, "custom_title_arg")) {
//     // variable_instance_remove(id, "custom_title_arg"); // Caused error
// }
// if (variable_instance_exists(id, "panel_background_sprite_arg")) {
//     // variable_instance_remove(id, "panel_background_sprite_arg"); // Caused error
// }
// Add more removals here if you add more arguments...

show_debug_message($"Generic UI Panel Created: Type='{panel_type}', Target='{target_data_source_id}', Title='{panel_title}', BG Sprite='{sprite_get_name(panel_background_sprite)}'");
#endregion

// ============================================================================
// 3. TYPE-SPECIFIC INITIALIZATION
// ============================================================================
#region 3.1 Type-Specific Setup
// Set default titles only if a custom title wasn't provided via arguments.
if (!_custom_title_provided) {
    switch (panel_type) {
        case "inventory":
            panel_title = "Inventory";
            if (instance_exists(target_data_source_id)) {
                // Example: panel_title = object_get_name(target_data_source_id.object_index) + " Inventory";
            }
            break;
        case "pop_info":
            panel_title = "Information";
            break;
        case "character_stats":
            panel_title = "Character Stats";
            break;
        // Add more cases as needed
    }
}
#endregion
