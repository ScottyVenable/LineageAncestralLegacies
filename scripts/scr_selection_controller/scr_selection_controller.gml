/// scr_selection_controller.gml
/// Version: 1.4 - 2024-05-19 // Scotty's Current Date - Pass config struct on panel creation

function scr_selection_controller(_selected_pop_id_arg) {

    show_debug_message("========================================================");
    show_debug_message($"DEBUG (scr_selection_controller V1.4): Called with _selected_pop_id_arg: {_selected_pop_id_arg}");

    // ============================================================================
    // 1. DESTROY EXISTING PANEL
    // ============================================================================
    #region 1.1 Destroy Old Panel
    if (global.ui_panel_instance != noone && instance_exists(global.ui_panel_instance)) {
        show_debug_message($"DEBUG (scr_selection_controller): Destroying existing panel ID: {global.ui_panel_instance}");
        instance_destroy(global.ui_panel_instance);
        global.ui_panel_instance = noone; 
    } else {
        show_debug_message("DEBUG (scr_selection_controller): No existing panel to destroy.");
    }
    #endregion

    // ============================================================================
    // 2. VALIDATE SELECTION & EARLY RETURN
    // ============================================================================
    #region 2.1 Validate Selected Pop
    if (_selected_pop_id_arg == noone) { /* ... exit logic ... */ show_debug_message("DEBUG (scr_selection_controller): No pop. Exiting."); show_debug_message("========================================================"); exit;}
    if (!instance_exists(_selected_pop_id_arg)) { /* ... exit logic ... */ show_debug_message("DEBUG (scr_selection_controller): Pop instance does not exist. Exiting."); show_debug_message("========================================================"); exit;}
    if (_selected_pop_id_arg.object_index != obj_pop) { /* ... exit logic ... */ show_debug_message("DEBUG (scr_selection_controller): Not obj_pop. Exiting."); show_debug_message("========================================================"); exit;}
    show_debug_message($"DEBUG (scr_selection_controller): Valid pop (ID: {_selected_pop_id_arg}). Proceeding.");
    #endregion

    // ============================================================================
    // 3. CONFIGURE AND CREATE NEW PANEL
    // ============================================================================
    #region 3.1 Panel Configuration
    var _panel_target_pop_id = _selected_pop_id_arg;
    var _panel_title_text = (variable_instance_exists(_panel_target_pop_id, "pop_identifier_string")) ? _panel_target_pop_id.pop_identifier_string : "Pop Info (" + string(_panel_target_pop_id) + ")";
    var _panel_bg_sprite = spr_UIborder_bone; 
    if (!sprite_exists(_panel_bg_sprite)) { show_debug_message($"CRITICAL DEBUG: spr_UIborder_bone MISSING!"); }

    var _panel_desired_width = 360;  
    var _panel_desired_height = 520; 
    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();
    var _margin_from_edge = 20;
    var _panel_x_position = clamp(max(_margin_from_edge, _gui_width - _panel_desired_width - _margin_from_edge), 0, _gui_width - _panel_desired_width);
    var _panel_y_position = clamp(_margin_from_edge, 0, _gui_height - _panel_desired_height);
     _panel_x_position = max(0, _panel_x_position); 
     _panel_y_position = max(0, _panel_y_position); 

    var _ui_layer_name = "UILayer"; 
    if (!layer_exists(_ui_layer_name)) { show_debug_message($"CRITICAL DEBUG: Layer '{_ui_layer_name}' MISSING!"); }
    #endregion

    #region 3.2 Create Panel Instance with Struct
    var _panel_config_struct = {
        panel_type_arg: "pop_info",
        target_data_source_id_arg: _panel_target_pop_id,
        custom_title_arg: _panel_title_text, // obj_UIPanel_Generic Create uses this for its panel_title
        panel_background_sprite_arg: _panel_bg_sprite
        // width and height are not part of _arg system in obj_UIPanel_Generic's Create
    };
    
    show_debug_message($"DEBUG (scr_selection_controller): Attempting to create obj_UIPanel_Generic with config: " + string(_panel_config_struct));
    if (!object_exists(obj_UIPanel_Generic)) { show_debug_message($"CRITICAL DEBUG: obj_UIPanel_Generic asset MISSING!"); show_debug_message("========================================================"); exit; }

    global.ui_panel_instance = instance_create_layer(
        _panel_x_position, 
        _panel_y_position, 
        _ui_layer_name, 
        obj_UIPanel_Generic, 
        _panel_config_struct // PASS THE STRUCT
    );

    if (!instance_exists(global.ui_panel_instance)) { show_debug_message($"ERROR: Failed to create obj_UIPanel_Generic. Returned: {global.ui_panel_instance}"); show_debug_message("========================================================"); exit;}
    show_debug_message($"DEBUG (scr_selection_controller): Created panel instance ID: {global.ui_panel_instance}. Now configuring further...");
    #endregion

    #region 3.3 Further Initialize Panel Instance (Width, Height, Visibility)
    with (global.ui_panel_instance) {
        // These are set directly as instance variables, not through _args.
        // obj_UIPanel_Generic's Draw GUI event checks for 'width' and 'height'.
        width  = _panel_desired_width;
        height = _panel_desired_height;
        visible = true; 
        
        // Other non-_arg initializations if needed
        if (!variable_instance_exists(id, "dragging")) { dragging = false; }
        if (!variable_instance_exists(id, "drag_offset_x")) { drag_offset_x = 0; }
        if (!variable_instance_exists(id, "drag_offset_y")) { drag_offset_y = 0; }
        
        // Log what the panel *should* have after this 'with' block
        show_debug_message($"DEBUG (scr_selection_controller): Panel ID {id} post-with config. " +
                           $"Title='{panel_title}', Target='{target_data_source_id}', Visible='{visible}', " +
                           $"W='{width}', H='{height}', PanelType='{panel_type}'");
    }
    #endregion

    #region 4.1 Finalization
    show_debug_message($"DEBUG (scr_selection_controller): UI Panel for pop {_panel_target_pop_id} setup complete.");
    #endregion
    show_debug_message("========================================================");
}