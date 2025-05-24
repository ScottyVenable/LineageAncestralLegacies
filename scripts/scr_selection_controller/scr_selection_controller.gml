/// scr_selection_controller.gml
/// Version: 1.8 - 2025-05-22 // Copilot: Text display updates only, removed panel visibility

function scr_selection_controller(_selected_pop_id_arg) {

    // Only show detailed logs if the selection state *changes* or is a valid pop.
    var _log_this_call = false;
    if (_selected_pop_id_arg != noone) {
        _log_this_call = true; // Always log if a specific pop is selected
    } else { // _selected_pop_id_arg is noone
        // If it's noone, only log if the UI wasn't already cleared.
        // This requires obj_controller to manage a state variable like 'ui_inspector_cleared'.
        // We assume obj_controller has: ui_inspector_cleared (true if N/A, false if displaying a pop)
        if (variable_instance_exists(obj_controller, "ui_inspector_cleared") && !obj_controller.ui_inspector_cleared) {
            _log_this_call = true;
        }
    }

    if (_log_this_call) {
        show_debug_message("========================================================");
        show_debug_message($"DEBUG (scr_selection_controller V1.8): Called with _selected_pop_id_arg: {_selected_pop_id_arg}");
    }

    // --- Validate Selected Pop for Text Updates ---
    // We don't exit early. If pop is invalid, _pop_for_text_update becomes noone,
    // which will then lead to text fields being set to "N/A".
    var _pop_for_text_update = _selected_pop_id_arg; // Use a temporary variable for clarity

    if (_pop_for_text_update != noone) {
        // Check if the instance still exists and is the correct object type.
        if (!instance_exists(_pop_for_text_update) || _pop_for_text_update.object_index != obj_pop) {
            show_debug_message($"DEBUG (scr_selection_controller): Invalid pop instance (ID: {_pop_for_text_update}) or not obj_pop. Clearing for text display.");
            _pop_for_text_update = noone; // Treat as no selection for the purpose of text updates
        }
    }

    if (_pop_for_text_update != noone) {
        if (_log_this_call) {
            show_debug_message($"DEBUG (scr_selection_controller): Valid pop (ID: {_pop_for_text_update}) identified for text updates.");
        }
        // When a valid pop is selected, the UI is no longer in its "cleared" state.
        if (variable_instance_exists(obj_controller, "ui_inspector_cleared")) {
            obj_controller.ui_inspector_cleared = false;
        }
    } else {
        if (_log_this_call) {
            show_debug_message("DEBUG (scr_selection_controller): No valid pop for text updates. Inspector fields will be set to 'N/A'.");
        }
    }

    // --- Update Inspector Panel Text Elements ---
    // This section updates the text fields based on _pop_for_text_update.
    // It relies on global.ui_text_elements being populated in obj_controller's Create event.

    if (variable_global_exists("ui_text_elements")) {
        // Attempt to get element IDs from the global struct.
        // It's good practice to check if these struct members exist before accessing them.
        var _name_el_id = (struct_exists(global.ui_text_elements, "pop_name_display")) ? global.ui_text_elements.pop_name_display : undefined;
        var _sex_el_id  = (struct_exists(global.ui_text_elements, "pop_sex_display")) ? global.ui_text_elements.pop_sex_display : undefined;
        var _age_el_id  = (struct_exists(global.ui_text_elements, "pop_age_display")) ? global.ui_text_elements.pop_age_display : undefined;

        if (_pop_for_text_update != noone) {
            // A valid pop is selected, so try to display its details.

            // Update Pop Name
            if (_name_el_id != undefined && is_real(_name_el_id) && layer_get_element_type(_name_el_id) != layerelementtype_undefined) {
                var _name_to_display = variable_instance_get(_pop_for_text_update, "pop_name");
                if (is_string(_name_to_display)) {
                    layer_text_text(_name_el_id, _name_to_display);
                    if (_log_this_call) show_debug_message($"DEBUG (scr_selection_controller): Updated Pop Name to: {_name_to_display}");
                } else {
                    layer_text_text(_name_el_id, "Err:Name"); // Display error if name is not a string
                    if (_log_this_call) show_debug_message("ERROR (scr_selection_controller): pop_name variable is not a string for the selected pop.");
                }
            } else {
                if (_log_this_call) show_debug_message("ERROR (scr_selection_controller): Pop Name display element is invalid or not found in global.ui_text_elements.");
            }

            // Update Pop Sex
            if (_sex_el_id != undefined && is_real(_sex_el_id) && layer_get_element_type(_sex_el_id) != layerelementtype_undefined) {
                var _sex_value = variable_instance_get(_pop_for_text_update, "sex");
                var _sex_string = "Unknown"; // Default value
                if (_sex_value == PopSex.MALE) { _sex_string = "Male"; }
                else if (_sex_value == PopSex.FEMALE) { _sex_string = "Female"; }
                layer_text_text(_sex_el_id, _sex_string);
                if (_log_this_call) show_debug_message($"DEBUG (scr_selection_controller): Updated Pop Sex to: {_sex_string}");
            } else {
                if (_log_this_call) show_debug_message("ERROR (scr_selection_controller): Pop Sex display element is invalid or not found in global.ui_text_elements.");
            }

            // Update Pop Age
            if (_age_el_id != undefined && is_real(_age_el_id) && layer_get_element_type(_age_el_id) != layerelementtype_undefined) {
                var _age_value = variable_instance_get(_pop_for_text_update, "age");
                if (is_real(_age_value)) {
                    layer_text_text(_age_el_id, string(floor(_age_value))); // Use floor to show whole numbers for age
                    if (_log_this_call) show_debug_message($"DEBUG (scr_selection_controller): Updated Pop Age to: {string(floor(_age_value))}");
                } else {
                    layer_text_text(_age_el_id, "Err:Age"); // Display error if age is not a number
                    if (_log_this_call) show_debug_message("ERROR (scr_selection_controller): age variable is not a real number for the selected pop.");
                }
            } else {
                if (_log_this_call) show_debug_message("ERROR (scr_selection_controller): Pop Age display element is invalid or not found in global.ui_text_elements.");
            }
        } else {
            // No valid pop is selected (_pop_for_text_update is noone), so set fields to "N/A".
            // Only log and update if the UI wasn't already cleared.
            if (variable_instance_exists(obj_controller, "ui_inspector_cleared") && !obj_controller.ui_inspector_cleared) {
                if (_log_this_call) show_debug_message("DEBUG (scr_selection_controller): Setting text fields to N/A as no valid pop is selected.");
                if (_name_el_id != undefined && is_real(_name_el_id) && layer_get_element_type(_name_el_id) != layerelementtype_undefined) {
                    layer_text_text(_name_el_id, "N/A");
                }
                if (_sex_el_id != undefined && is_real(_sex_el_id) && layer_get_element_type(_sex_el_id) != layerelementtype_undefined) {
                    layer_text_text(_sex_el_id, "N/A");
                }
                if (_age_el_id != undefined && is_real(_age_el_id) && layer_get_element_type(_age_el_id) != layerelementtype_undefined) {
                    layer_text_text(_age_el_id, "N/A");
                }
                obj_controller.ui_inspector_cleared = true; // Mark UI as cleared
            }
        }
    } else {
        // This case should ideally not be reached if obj_controller initializes global.ui_text_elements correctly.
        if (_log_this_call) show_debug_message("CRITICAL ERROR (scr_selection_controller): global.ui_text_elements struct itself does not exist. Cannot update UI text.");
    }

    if (_log_this_call) {
        show_debug_message("========================================================");
    }
}