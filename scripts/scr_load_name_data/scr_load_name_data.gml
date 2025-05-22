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
    var _male_prefixes_path   = "datafiles/namedata/pops/tribal_stage/tribal_male_prefix.json";
    var _male_suffixes_path   = "datafiles/namedata/pops/tribal_stage/tribal_male_suffix.json";
    var _female_prefixes_path = "datafiles/namedata/pops/tribal_stage/tribal_female_prefix.json";
    var _female_suffixes_path = "datafiles/namedata/pops/tribal_stage/tribal_female_suffix.json";
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
    global.male_prefixes    = scr_load_json_array_from_file(_male_prefixes_path);
    global.male_suffixes    = scr_load_json_array_from_file(_male_suffixes_path);
    global.female_prefixes  = scr_load_json_array_from_file(_female_prefixes_path);
    global.female_suffixes  = scr_load_json_array_from_file(_female_suffixes_path);
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
    #endregion
}

function scr_load_json_array_from_file(_path) {
    var arr = [];
    if (file_exists(_path)) {
        var buffer = buffer_load(_path);
        var json_str = buffer_read(buffer, buffer_string, buffer_get_size(buffer));
        buffer_delete(buffer);
        arr = json_parse(json_str);
    }
    return arr;
}