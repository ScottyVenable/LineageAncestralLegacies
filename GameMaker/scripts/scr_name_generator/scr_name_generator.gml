/// scr_name_generator.gml
/// Provides a generic name generation interface.
/// If given an entity profile and sex, routes to the appropriate name function.
/// Version: 1.1 - 2025-05-28 // Updated to use scr_generate_pop_name for pop names
function scr_name_generator(_profile_struct, _sex) {
    // Use dynamic script execution to ensure proper resolution
    var _script_id = asset_get_index("scr_generate_pop_name");
    if (script_exists(_script_id)) {
        // Execute the central name generation script dynamically
        return script_execute(_script_id, _profile_struct, _sex);
    } else {
        show_debug_message("ERROR: scr_generate_pop_name script not found. Cannot generate pop name.");
        return "";
    }
}

/// scr_name_for_pop: Generates a pop name based on profile and sex
/// DEPRECATED: This function's logic is now handled by scr_generate_pop_name.
/// It is kept for now to maintain compatibility if other scripts call it directly,
/// but it simply forwards the call to scr_generate_pop_name.
function scr_name_for_pop(_profile_struct, _sex) {
    show_debug_message("Note: scr_name_for_pop is being called. Consider updating calls to use scr_generate_pop_name directly.");
    var _script_id = asset_get_index("scr_generate_pop_name");
    if (script_exists(_script_id)) {
        return script_execute(_script_id, _profile_struct, _sex);
    } else {
        show_debug_message("ERROR: scr_generate_pop_name script not found when calling scr_name_for_pop.");
        return "";
    }
}