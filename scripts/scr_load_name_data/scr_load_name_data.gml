/// scr_load_name_data.gml
///
/// Purpose:
///   Loads name prefixes and suffixes from .txt files into global arrays for name generation.
///
/// Metadata:
///   Summary:       Loads male/female name parts from text files into global arrays
///   Usage:         Call once at game start (e.g., obj_controller Create Event)
///   Parameters:    None
///   Returns:       void
///   Tags:          [data][utility]
///   Version:       1.0 — 2025-05-22
///   Dependencies:  None
function scr_load_name_data() {
    // =========================================================================
    // 0. IMPORTS & CACHES
    // =========================================================================
    #region 0.1 Imports & Cached Locals
    // None needed
    #endregion
    // =========================================================================
    // 1. VALIDATION & EARLY RETURNS
    // =========================================================================
    #region 1.1 Parameter Validation
    // No parameters
    #endregion
    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS
    // =========================================================================
    #region 2.1 Local Constants
    // Corrected paths to the .txt name data files
    var _male_prefixes_path   = "data/names/male_name_prefixes.txt";
    var _male_suffixes_path   = "data/names/male_name_suffixes.txt";
    var _female_prefixes_path = "data/names/female_name_prefixes.txt";
    var _female_suffixes_path = "data/names/female_name_suffixes.txt";
    #endregion
    // =========================================================================
    // 3. INITIALIZATION & STATE SETUP
    // =========================================================================
    #region 3.1 One‐Time Setup
    // None needed
    #endregion
    // =========================================================================
    // 4. CORE LOGIC
    // =========================================================================
    #region 4.1. Main Behavior / Utility Logic
    // Load name data from text files
    global.male_prefixes    = scr_load_text_file_lines(_male_prefixes_path);
    global.male_suffixes    = scr_load_text_file_lines(_male_suffixes_path);
    global.female_prefixes  = scr_load_text_file_lines(_female_prefixes_path);
    global.female_suffixes  = scr_load_text_file_lines(_female_suffixes_path);
    #endregion
    // =========================================================================
    // 5. CLEANUP & RETURN
    // =========================================================================
    #region 5.1 Cleanup & Return
    // No cleanup needed
    #endregion
    // =========================================================================
    // 6. DEBUG/PROFILING (Optional)
    // =========================================================================
    #region 6.1 Debug & Profile Hooks
    // Uncomment for debugging:
    // show_debug_message("Loaded name data: " + string(array_length(global.male_prefixes)) + " male prefixes, " + string(array_length(global.female_prefixes)) + " female prefixes.");
    // Debugging: Log the number of prefixes and suffixes loaded
    show_debug_message("Loaded male prefixes: " + string(array_length(global.male_prefixes)));
    show_debug_message("Loaded male suffixes: " + string(array_length(global.male_suffixes)));
    show_debug_message("Loaded female prefixes: " + string(array_length(global.female_prefixes)));
    show_debug_message("Loaded female suffixes: " + string(array_length(global.female_suffixes)));
    // Debugging: Log the file paths being accessed
    show_debug_message("Attempting to load male prefixes from: " + _male_prefixes_path);
    show_debug_message("Attempting to load male suffixes from: " + _male_suffixes_path);
    show_debug_message("Attempting to load female prefixes from: " + _female_prefixes_path);
    show_debug_message("Attempting to load female suffixes from: " + _female_suffixes_path);
    #endregion
}

// Updated helper function to load lines from a text file into an array
function scr_load_text_file_lines(_path) {
    var _list = ds_list_create(); // Initialize the DS list at the start
    var _array = []; // Initialize an empty array

    // Check if the file exists before attempting to open it
    if (!file_exists(_path)) {
        show_debug_message("Error: File not found - " + _path);
        ds_list_destroy(_list); // Clean up the DS list
        return _array; // Return an empty array as fallback
    }

    var _file = file_text_open_read(_path);

    if (_file != -1) {
        while (!file_text_eof(_file)) {
            var _line = file_text_read_string(_file); // Read the entire line
            var _split_values = string_split(_line, ","); // Split by commas
            for (var i = 0; i < array_length(_split_values); i++) {
                ds_list_add(_list, string_trim(_split_values[i])); // Trim and add each value
            }
            file_text_readln(_file);
        }
        file_text_close(_file);
    } else {
        show_debug_message("Error: Unable to open file - " + _path);
        ds_list_destroy(_list); // Clean up the DS list
        return _array; // Return an empty array as fallback
    }

    _array = scr_ds_list_to_array(_list); // Use the custom function to convert ds_list to array
    ds_list_destroy(_list); // Destroy the DS list to prevent memory leaks

    return _array;
}