/// scr_custom_functions.gml
///
/// Purpose:
///   This script file acts as a container for various custom utility functions
///   that don't belong to a more specific category or are too small to warrant
///   their own individual script files.
///
/// Metadata:
///   Summary:       Collection of miscellaneous utility functions.
///   Usage:         Call specific functions from this script as needed by other game systems.
///   Parameters:    See individual functions.
///   Returns:       See individual functions.
///   Tags:          [utility][collection]
///   Version:       1.0 - 2025-05-23
///   Dependencies:  None

// =========================================================================
// 0. IMPORTS & CACHES
// =========================================================================
#region 0.1 Imports & Cached Locals
// No global imports/caches for this collection script.
#endregion

// =========================================================================
// 1. VALIDATION & EARLY RETURNS (N/A at script level)
// =========================================================================
// (Validation is handled within individual functions)

// =========================================================================
// 2. CONFIGURATION & CONSTANTS (N/A at script level)
// =========================================================================
// (Constants are handled within individual functions if needed)

// =========================================================================
// 3. INITIALIZATION & STATE SETUP (N/A at script level)
// =========================================================================
// (Initialization is handled within individual functions if needed)

// =========================================================================
// 4. CORE LOGIC (Individual Functions)
// =========================================================================

#region 4.1 ds_list_to_array
/// ---
/// ds_list_to_array(_list)
/// ---
/// Purpose:
///   Converts a ds_list into a standard GML array.
///
/// Metadata (for function):
///   Summary:       Converts a ds_list to an array.
///   Usage:         Utility function for data structure operations.
///                  e.g., var _my_array = ds_list_to_array(my_ds_list);
///   Parameters:    _list : Id.DsList — The ds_list to convert.
///   Returns:       Array<Any> — A GML array containing the elements of the ds_list. Returns an empty array if input is invalid.
///   Tags:          [utility][ds_list][array][conversion]
///   Version:       1.1 - 2025-05-23 // Integrated into scr_custom_functions and updated header
///   Dependencies:  None

function ds_list_to_array(_list) {
    // =========================================================================
    // 0. IMPORTS & CACHES (Function Specific)
    // =========================================================================
    #region 0.1 Imports & Cached Locals
    // No specific imports/caches needed for this function.
    #endregion

    // =========================================================================
    // 1. VALIDATION & EARLY RETURNS (Function Specific)
    // =========================================================================
    #region 1.1 Parameter Validation
    // Check if the input is a valid ds_list
    if (!ds_exists(_list, ds_type_list)) {
        show_debug_message("ERROR: ds_list_to_array() — Invalid _list parameter: not a valid ds_list.");
        return []; // Return an empty array if the input is invalid
    }
    #endregion

    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS (Function Specific)
    // =========================================================================
    #region 2.1 Local Constants
    // No local constants needed.
    #endregion

    // =========================================================================
    // 3. INITIALIZATION & STATE SETUP (Function Specific)
    // =========================================================================
    #region 3.1 One-Time Setup / State Variables
    // No state setup needed.
    #endregion

    // =========================================================================
    // 4. CORE LOGIC (Function Specific)
    // =========================================================================
    #region 4.1 Main Behavior / Utility Logic
    // Create an array to store the elements of the ds_list
    var _array = [];

    // Loop through the ds_list and copy each element into the array
    // LEARNING POINT: ds_list_size() gives the number of items in a ds_list.
    // ds_list_find_value() retrieves an item at a specific index (0-based).
    for (var i = 0; i < ds_list_size(_list); i++) {
        array_push(_array, ds_list_find_value(_list, i));
    }
    #endregion

    // =========================================================================
    // 5. CLEANUP & RETURN (Function Specific)
    // =========================================================================
    #region 5.1 Cleanup & Return Value
    return _array; // Return the resulting array
    #endregion
    
    // =========================================================================
    // 6. DEBUG/PROFILING (Optional - Function Specific)
    // =========================================================================
    #region 6.1 Debug & Profile Hooks
    // No specific debug hooks for this function.
    #endregion
}
#endregion

// =========================================================================
// 5. CLEANUP & RETURN (N/A at script level)
// =========================================================================

// =========================================================================
// 6. DEBUG/PROFILING (Optional - N/A at script level)
// =========================================================================
