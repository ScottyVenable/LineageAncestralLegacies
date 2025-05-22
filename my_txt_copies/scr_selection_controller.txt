/// scr_selection_controller.gml
/// Version: 1.4 - 2024-05-19 // Scotty's Current Date - Pass config struct on panel creation

function scr_selection_controller(_selected_pop_id_arg) {

    show_debug_message("========================================================");
    show_debug_message($"DEBUG (scr_selection_controller V1.4): Called with _selected_pop_id_arg: {_selected_pop_id_arg}");


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
    // 3. CONFIGURE INSPECTOR PANEL TO DISPLAY DATA
    // ============================================================================

    show_debug_message("========================================================");
}