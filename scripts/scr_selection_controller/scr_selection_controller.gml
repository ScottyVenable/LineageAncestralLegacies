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
    #region 3.1 Update Inspector Panel Text Elements
    // This section assumes that global.ui_text_elements has been populated in obj_controller's Create event
    // with references to the text elements in your Inspector_Window, identified by placeholder text.

    if (instance_exists(_selected_pop_id_arg)) {
        // It's good practice to check if the text elements themselves exist before trying to update them.
        // This uses the references stored in global.ui_text_elements.

        // Update Pop Name
        if (variable_global_exists("ui_text_elements") && struct_exists(global.ui_text_elements, "pop_name_display")) {
            var _name_element_id = global.ui_text_elements.pop_name_display;
            if (layer_has_instance("UI", _name_element_id)) { // Assuming text elements are on "UI" layer
                // The pop_name variable should exist on your obj_pop instances, set by scr_generate_pop_details
                var _name_to_display = variable_instance_get(_selected_pop_id_arg, "pop_name");
                if (is_string(_name_to_display)) {
                    layer_text_text(_name_element_id, _name_to_display);
                    show_debug_message($"DEBUG (scr_selection_controller): Updated Pop Name display to: {_name_to_display}");
                } else {
                    layer_text_text(_name_element_id, "Error: Name not string");
                    show_debug_message("ERROR (scr_selection_controller): pop_name variable is not a string for selected pop.");
                }
            } else {
                show_debug_message("ERROR (scr_selection_controller): Pop Name display element ID not found on UI layer.");
            }
        } else {
            show_debug_message("ERROR (scr_selection_controller): global.ui_text_elements.pop_name_display not found.");
        }

        // Update Pop Sex
        if (variable_global_exists("ui_text_elements") && struct_exists(global.ui_text_elements, "pop_sex_display")) {
            var _sex_element_id = global.ui_text_elements.pop_sex_display;
            if (layer_has_instance("UI", _sex_element_id)) {
                // The sex variable should exist, set by scr_generate_pop_details (e.g., PopSex.MALE or PopSex.FEMALE)
                var _sex_value = variable_instance_get(_selected_pop_id_arg, "sex");
                var _sex_string = "Unknown"; // Default string
                if (_sex_value == PopSex.MALE) { _sex_string = "Male"; }
                else if (_sex_value == PopSex.FEMALE) { _sex_string = "Female"; }
                
                layer_text_text(_sex_element_id, _sex_string);
                show_debug_message($"DEBUG (scr_selection_controller): Updated Pop Sex display to: {_sex_string}");
            } else {
                show_debug_message("ERROR (scr_selection_controller): Pop Sex display element ID not found on UI layer.");
            }
        } else {
            show_debug_message("ERROR (scr_selection_controller): global.ui_text_elements.pop_sex_display not found.");
        }

        // Update Pop Age
        if (variable_global_exists("ui_text_elements") && struct_exists(global.ui_text_elements, "pop_age_display")) {
            var _age_element_id = global.ui_text_elements.pop_age_display;
            if (layer_has_instance(layer_get_id("UI"), _age_element_id)) {
                // The age variable should exist, set by scr_generate_pop_details
                var _age_value = variable_instance_get(_selected_pop_id_arg, "age");
                if (is_real(_age_value)) {
                    layer_text_text(_age_element_id, string(_age_value));
                    show_debug_message($"DEBUG (scr_selection_controller): Updated Pop Age display to: {string(_age_value)}");
                } else {
                    layer_text_text(_age_element_id, "Error: Age not number");
                    show_debug_message("ERROR (scr_selection_controller): age variable is not a number for selected pop.");
                }
            } else {
                show_debug_message("ERROR (scr_selection_controller): Pop Age display element ID not found on UI layer.");
            }
        } else {
            show_debug_message("ERROR (scr_selection_controller): global.ui_text_elements.pop_age_display not found.");
        }

    } else {
        // If no pop is selected (or becomes invalid), clear the display fields or set to N/A
        if (variable_global_exists("ui_text_elements")) {
            if (struct_exists(global.ui_text_elements, "pop_name_display") && layer_has_instance(layer_get_id("UI"), global.ui_text_elements.pop_name_display)) {
                layer_text_text(global.ui_text_elements.pop_name_display, "N/A");
            }
            if (struct_exists(global.ui_text_elements, "pop_sex_display") && layer_has_instance(layer_get_id("UI"), global.ui_text_elements.pop_sex_display)) {
                layer_text_text(global.ui_text_elements.pop_sex_display, "N/A");
            }
            if (struct_exists(global.ui_text_elements, "pop_age_display") && layer_has_instance(layer_get_id("UI"), global.ui_text_elements.pop_age_display)) {
                layer_text_text(global.ui_text_elements.pop_age_display, "N/A");
            }
            show_debug_message("DEBUG (scr_selection_controller): No valid pop selected, cleared/reset inspector fields.");
        }
    }
    #endregion

    show_debug_message("========================================================");
}