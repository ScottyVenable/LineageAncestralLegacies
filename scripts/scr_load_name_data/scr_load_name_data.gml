/// scr_load_name_data.gml
///
/// Purpose:
///   Loads name prefixes and suffixes from .txt files into global arrays.
///   These arrays are then used for generating culturally appropriate names for pops.
///
/// Metadata:
///   Summary:       Loads male and female name components (prefixes, suffixes) from text files into global arrays.
///   Usage:         Call `load_name_data()` once at the beginning of the game (e.g., in a controller object's Create Event).
///   Parameters:    None
///   Returns:       void (This function modifies global variables directly: `global.male_prefixes`, `global.male_suffixes`, `global.female_prefixes`, `global.female_suffixes`)
///   Tags:          [data][utility][names][generation][initialization][file_io]
///   Version:       1.1 - 2025-05-23 // Renamed functions, aligned with TEMPLATE_SCRIPT.
///   Dependencies:  `ds_list_to_array()` (from `ds_list_to_array.gml`). Text files in `data/names/`.
///   Creator:       GameDev AI (Originally) / Your Name // Please update creator if known
///   Created:       2025-05-22 // Assumed creation date, please update if known
///   Last Modified: 2025-05-23 by Copilot // Updated to match template, renamed functions

// =========================================================================
// 0. IMPORTS & CACHES (Script-level)
// =========================================================================
#region 0.1 Global Scope Dependencies
// This script relies on `ds_list_to_array` being available globally from `ds_list_to_array.gml`.
// No direct script-level imports here, but function dependencies are noted in metadata.
#endregion

// =========================================================================
// (Sections 1-3 are not directly applicable for a script file that only defines functions)
// (unless there was script-level execution code outside functions)
// =========================================================================

// =========================================================================
// 4. CORE LOGIC (Function Definitions)
// =========================================================================

#region 4.1 Main Data Loading Function: load_name_data()
/// @function load_name_data()
/// @description Loads all specified name data files (prefixes, suffixes for male/female) into global arrays.
function load_name_data() {
    // =========================================================================
    // 4.1.0. IMPORTS & CACHES (Function-local)
    // =========================================================================
    #region FunctionLocal_0.1 Imports & Cached Locals
    // Cache the helper function for loading lines from a file.
    var _load_lines_func = load_text_file_lines;
    #endregion

    // =========================================================================
    // 4.1.1. VALIDATION & EARLY RETURNS (Function-local)
    // =========================================================================
    #region FunctionLocal_1.1 Parameter Validation
    // No parameters for this function.
    #endregion
    #region FunctionLocal_1.2 Pre-condition Checks
    // Could add a check if data is already loaded to prevent re-loading, if necessary.
    // e.g., if (global.name_data_loaded) { show_debug_message("Name data already loaded."); return; }
    #endregion

    // =========================================================================
    // 4.1.2. CONFIGURATION & CONSTANTS (Function-local)
    // =========================================================================
    #region FunctionLocal_2.1 Local Constants - File Paths
    // Define the paths to the text files containing name components.
    // It's good practice to keep these paths easily configurable at the top of the function.
    var _male_prefixes_path   = "data/names/male_name_prefixes.txt";
    var _male_suffixes_path   = "data/names/male_name_suffixes.txt";
    var _female_prefixes_path = "data/names/female_name_prefixes.txt";
    var _female_suffixes_path = "data/names/female_name_suffixes.txt";
    #endregion

    // =========================================================================
    // 4.1.3. INITIALIZATION & STATE SETUP (Function-local)
    // =========================================================================
    #region FunctionLocal_3.1 Global Variable Initialization
    // Ensure global arrays are initialized (or re-initialized) before loading.
    // This prevents issues if the function is called multiple times, though ideally it's called once.
    global.male_prefixes    = [];
    global.male_suffixes    = [];
    global.female_prefixes  = [];
    global.female_suffixes  = [];
    #endregion

    // =========================================================================
    // 4.1.4. CORE LOGIC (Function-local) - Loading Data
    // =========================================================================
    #region FunctionLocal_4.1 Load Name Data from Files
    // Use the helper function to load lines from each specified file into the corresponding global array.
    show_debug_message("Attempting to load male prefixes from: " + _male_prefixes_path);
    global.male_prefixes    = _load_lines_func(_male_prefixes_path);
    
    show_debug_message("Attempting to load male suffixes from: " + _male_suffixes_path);
    global.male_suffixes    = _load_lines_func(_male_suffixes_path);
    
    show_debug_message("Attempting to load female prefixes from: " + _female_prefixes_path);
    global.female_prefixes  = _load_lines_func(_female_prefixes_path);
    
    show_debug_message("Attempting to load female suffixes from: " + _female_suffixes_path);
    global.female_suffixes  = _load_lines_func(_female_suffixes_path);
    
    // global.name_data_loaded = true; // Optional: set a flag indicating data has been loaded.
    #endregion

    // =========================================================================
    // 4.1.5. CLEANUP & RETURN (Function-local)
    // =========================================================================
    #region FunctionLocal_5.1 Cleanup
    // No specific cleanup needed within this function beyond what load_text_file_lines handles.
    #endregion
    #region FunctionLocal_5.2 Return Value
    // This function does not return a value; it modifies global variables.
    #endregion

    // =========================================================================
    // 4.1.6. DEBUG/PROFILING (Function-local)
    // =========================================================================
    #region FunctionLocal_6.1 Debug Logging
    // Log the number of prefixes and suffixes loaded for verification.
    show_debug_message("Loaded male prefixes: " + string(array_length(global.male_prefixes)));
    show_debug_message("Loaded male suffixes: " + string(array_length(global.male_suffixes)));
    show_debug_message("Loaded female prefixes: " + string(array_length(global.female_prefixes)));
    show_debug_message("Loaded female suffixes: " + string(array_length(global.female_suffixes)));
    #endregion
}
#endregion

#region 4.2 Helper Function: load_text_file_lines()
/// @function load_text_file_lines(_path)
/// @description Reads all lines from a given text file, splits lines by comma if present,
///              trims whitespace from each part, and returns them as an array of strings.
/// @param {string} _path The path to the text file (relative to the game's working directory or included files).
/// @returns {Array<String>} An array of strings, where each string is a processed line or part of a line from the file.
///                        Returns an empty array if the file doesn't exist or cannot be opened.
function load_text_file_lines(_path) {
    // =========================================================================
    // Helper_0. IMPORTS & CACHES
    // =========================================================================
    #region Helper_0.1 Imports & Cached Locals
    // Cache the ds_list_to_array function if it's used frequently within a loop (not the case here, but good practice).
    // var _ds_list_to_array_func = ds_list_to_array; // Assuming ds_list_to_array is globally available
    #endregion

    // =========================================================================
    // Helper_1. VALIDATION & EARLY RETURNS
    // =========================================================================
    #region Helper_1.1 Parameter Validation
    if (!is_string(_path) || string_length(_path) == 0) {
        show_debug_message("ERROR (load_text_file_lines): Invalid or empty path provided.");
        return [];
    }
    #endregion
    #region Helper_1.2 Pre-condition Checks - File Existence
    // Check if the file exists before attempting to open it. This prevents errors.
    if (!file_exists(_path)) {
        show_debug_message("ERROR (load_text_file_lines): File not found - " + _path);
        return []; // Return an empty array as a fallback if the file doesn't exist.
    }
    #endregion

    // =========================================================================
    // Helper_2. CONFIGURATION & CONSTANTS
    // =========================================================================
    #region Helper_2.1 Local Constants
    // No specific constants needed for this helper.
    #endregion

    // =========================================================================
    // Helper_3. INITIALIZATION & STATE SETUP
    // =========================================================================
    #region Helper_3.1 Data Structures
    var _list = ds_list_create(); // Create a temporary ds_list to hold lines before converting to an array.
                                  // ds_lists are efficient for adding many items.
    var _array = [];              // Initialize an empty array for the final result.
    #endregion

    // =========================================================================
    // Helper_4. CORE LOGIC - File Reading
    // =========================================================================
    #region Helper_4.1 Open and Read File
    var _file = file_text_open_read(_path); // Attempt to open the file for reading.

    if (_file != -1) { // Check if the file was opened successfully.
        // Loop until the end of the file (eof) is reached.
        while (!file_text_eof(_file)) {
            var _line = file_text_read_string(_file); // Read the current entire line as a string.
            
            // Split the line by commas. This allows multiple names/parts per line in the source file.
            var _split_values = string_split(_line, ","); 
            
            // Iterate through the parts obtained after splitting.
            for (var i = 0; i < array_length(_split_values); i++) {
                var _trimmed_value = string_trim(_split_values[i]); // Remove leading/trailing whitespace.
                if (string_length(_trimmed_value) > 0) { // Only add non-empty strings.
                    ds_list_add(_list, _trimmed_value); 
                }
            }
            file_text_readln(_file); // Advance to the next line for the next iteration.
        }
        file_text_close(_file); // Close the file once reading is complete.
    } else {
        // If the file could not be opened (e.g., due to permissions, though file_exists should catch most issues).
        show_debug_message("ERROR (load_text_file_lines): Unable to open file - " + _path);
        // Cleanup ds_list even on error before returning.
        ds_list_destroy(_list);
        return []; // Return an empty array as a fallback.
    }
    #endregion

    // =========================================================================
    // Helper_5. CLEANUP & RETURN
    // =========================================================================
    #region Helper_5.1 Convert to Array and Cleanup DS_List
    // Convert the ds_list to a standard GameMaker array.
    // This uses the `ds_list_to_array` function (expected to be globally available from `ds_list_to_array.gml`).
    if (script_exists(ds_list_to_array)) { // Check if the conversion script exists
        _array = ds_list_to_array(_list); 
    } else {
        show_debug_message("CRITICAL ERROR (load_text_file_lines): ds_list_to_array script not found! Cannot convert list for " + _path);
        // Fallback: Manually convert if ds_list_to_array is missing (less efficient for large lists but functional)
        // for (var i = 0; i < ds_list_size(_list); i++) {
        //     array_push(_array, _list[| i]);
        // }
    }
    
    ds_list_destroy(_list); // IMPORTANT: Destroy the ds_list to prevent memory leaks.
    #endregion
    #region Helper_5.2 Return Value
    return _array; // Return the populated array (or an empty one if errors occurred).
    #endregion

    // =========================================================================
    // Helper_6. DEBUG/PROFILING (Optional)
    // =========================================================================
    #region Helper_6.1 Debug & Profile Hooks
    // Example debug: 
    // show_debug_message(string_format("load_text_file_lines: Loaded {0} items from {1}", array_length(_array), _path));
    #endregion
}
#endregion