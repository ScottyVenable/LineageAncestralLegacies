/// scr_selection_controller.gml
///
/// Purpose:
///     Manages pop selection and displays the "pop_info" UI panel
///     (obj_UIPanel_Generic) for a single selected pop.
///     Ensures the panel is correctly sized and configured.
///
/// Metadata:
///     Summary:        Handles single pop selection and UI panel display.
///     Usage:          Called when a pop selection changes or is confirmed
///                     (e.g., in obj_controller's mouse click or selection box logic).
///     Parameters:
///         _selected_pop_id : instance_id — The ID of the single pop that has been selected.
///                                          Pass `noone` if no single pop is selected or to close the panel.
///     Returns:        void
///     Tags:           [selection][ui][controller][panel_management]
///     Version:        1.1 - 2025-05-18 (Added explicit width/height for UI Panel)
///     Dependencies:   obj_UIPanel_Generic, global.ui_panel_instance, instance_exists(),
///                     instance_destroy(), instance_create_layer(), display_get_gui_width(),
///                     Pop specific variables (e.g., pop_identifier_string),
///                     Sprite resources (e.g., spr_UIborder_bone).

function scr_selection_controller(_selected_pop_id) {

    // ============================================================================
    // 0. IMPORTS & CACHES / PRE-CHECKS
    // ============================================================================
    #region 0.1 Pre-checks
    // (No specific imports needed for this script)
    #endregion

    // ============================================================================
    // 1. DESTROY EXISTING PANEL
    // ============================================================================
    #region 1.1 Destroy Old Panel
    // If a UI panel instance already exists, destroy it before creating a new one
    // or if no pop is selected.
    if (global.ui_panel_instance != noone && instance_exists(global.ui_panel_instance)) {
        instance_destroy(global.ui_panel_instance);
        global.ui_panel_instance = noone; // Reset the global variable
    }
    #endregion

    // ============================================================================
    // 2. VALIDATE SELECTION & EARLY RETURN
    // ============================================================================
    #region 2.1 Validate Selected Pop
    // If no valid pop is selected, we've already closed any existing panel, so just exit.
    if (_selected_pop_id == noone || !instance_exists(_selected_pop_id)) {
        show_debug_message("DEBUG (scr_selection_controller): No valid pop selected or told to close panel. UI Panel closed/not shown.");
        exit;
    }

    // Ensure the selected instance is actually a pop (optional, but good practice)
    // if (object_get_name(_selected_pop_id.object_index) != "obj_pop") {
    //     show_debug_message($"Warning (scr_selection_controller): Selected instance {_selected_pop_id} is not obj_pop.");
    //     exit;
    // }
    #endregion

    // ============================================================================
    // 3. CONFIGURE AND CREATE NEW PANEL
    // ============================================================================
    #region 3.1 Panel Configuration
    var _panel_target_pop_id = _selected_pop_id;
    var _panel_title_text = "Information"; // Default title

    // Attempt to get a more specific title, e.g., the pop's identifier string
    if (variable_instance_exists(_panel_target_pop_id, "pop_identifier_string")) {
        _panel_title_text = _panel_target_pop_id.pop_identifier_string;
    } else {
        _panel_title_text = "Pop Information"; // Fallback if identifier string isn't found
    }
    
    var _panel_bg_sprite = spr_UIborder_bone; // Your chosen background sprite for the panel

    // Define panel dimensions and position
    // These values can be adjusted based on your UI layout preferences.
    var _panel_desired_width = 360;  // Explicitly set the desired width for the pop_info panel
    var _panel_desired_height = 520; // Explicitly set the desired height, allowing space for all info

    // Position the panel (e.g., top-right of the GUI)
    // Ensure it doesn't go off-screen if GUI size is smaller than panel size + margin
    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();
    var _margin_from_edge = 20;

    var _panel_x_position = max(_margin_from_edge, _gui_width - _panel_desired_width - _margin_from_edge);
    var _panel_y_position = _margin_from_edge;
    
    // Ensure panel is not positioned off-screen if the GUI is very small
    if (_panel_x_position + _panel_desired_width > _gui_width - _margin_from_edge) {
        _panel_x_position = _gui_width - _panel_desired_width - _margin_from_edge;
    }
    if (_panel_y_position + _panel_desired_height > _gui_height - _margin_from_edge) {
        _panel_y_position = _gui_height - _panel_desired_height - _margin_from_edge;
    }
    _panel_x_position = max(0, _panel_x_position); // Don't let it go negative
    _panel_y_position = max(0, _panel_y_position); // Don't let it go negative


    var _ui_layer_name = "UILayer"; // IMPORTANT: Ensure this layer exists in your room editor
                                    // or is created dynamically at game start.
    #endregion

    #region 3.2 Create Panel Instance
    show_debug_message($"DEBUG (scr_selection_controller): Creating UI Panel for pop ID: {_panel_target_pop_id} at ({_panel_x_position}, {_panel_y_position}) with size ({_panel_desired_width}x{_panel_desired_height})");

    global.ui_panel_instance = instance_create_layer(_panel_x_position, _panel_y_position, _ui_layer_name, obj_UIPanel_Generic);

    if (global.ui_panel_instance == noone || !instance_exists(global.ui_panel_instance)) {
        show_debug_message($"ERROR (scr_selection_controller): Failed to create obj_UIPanel_Generic instance on layer '{_ui_layer_name}'.");
        exit;
    }
    #endregion

    #region 3.3 Initialize Panel Instance Variables
    // Use 'with' to set variables on the newly created panel instance
    with (global.ui_panel_instance) {
        panel_type              = "pop_info";
        panel_title             = _panel_title_text; // Set the dynamic or default title
        target_data_source_id   = _panel_target_pop_id;
        panel_background_sprite = _panel_bg_sprite;
        
        // Explicitly set width and height for this instance
        width  = _panel_desired_width;
        height = _panel_desired_height;
        
        // Initialize dragging variables if they are not initialized in obj_UIPanel_Generic's Create Event.
        // It's generally better to initialize these in the panel's own Create Event.
        if (!variable_instance_exists(id, "dragging")) {
            dragging = false;
        }
        if (!variable_instance_exists(id, "drag_offset_x")) {
            drag_offset_x = 0;
        }
        if (!variable_instance_exists(id, "drag_offset_y")) {
            drag_offset_y = 0;
        }
        
        // If your panel has a close button, you might want to set its initial state or action here too.
    }
    #endregion

    // ============================================================================
    // 4. CLEANUP & FINAL ACTIONS (if any)
    // ============================================================================
    #region 4.1 Finalization
    // (No specific cleanup needed in this script after panel creation)
    show_debug_message($"DEBUG (scr_selection_controller): UI Panel for pop {_panel_target_pop_id} successfully configured.");
    #endregion
}
