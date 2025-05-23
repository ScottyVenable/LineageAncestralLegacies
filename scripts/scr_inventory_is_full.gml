/// scr_inventory_is_full.gml
///
/// Purpose:
///   Checks if the given inventory struct is full based on a predefined capacity.
///
/// Metadata:
///   Summary:       Determines if an inventory has reached its maximum capacity.
///   Usage:         Call anywhere an inventory's fullness needs to be checked.
///                  e.g., if (scr_inventory_is_full(my_pop.inventory)) { ... }
///   Parameters:    _inventory : struct — The inventory struct to check (e.g., a pop's `inventory` variable).
///                                      Assumes inventory items are stored as { item_id_string : quantity }.
///   Returns:       boolean — True if the total number of items meets or exceeds `max_capacity`, false otherwise.
///   Tags:          [utility][inventory][capacity][check]
///   Version:       1.2 - 2025-05-23 // Fully aligned with TEMPLATE_SCRIPT structure.
///   Dependencies:  None
///   Creator:       GameDev AI (Originally) / Your Name
///   Created:       2025-05-20 // Assumed creation date, please update if known
///   Last Modified: 2025-05-23 by Copilot // Updated to match template

function scr_inventory_is_full(_inventory) {
    // =========================================================================
    // 0. IMPORTS & CACHES
    // =========================================================================
    #region 0.1 Imports & Cached Locals
    // No specific imports or caches needed for this simple utility.
    #endregion

    // =========================================================================
    // 1. VALIDATION & EARLY RETURNS
    // =========================================================================
    #region 1.1 Parameter Validation
    if (!is_struct(_inventory)) {
        show_debug_message("ERROR: scr_inventory_is_full() — Invalid _inventory parameter: not a struct.");
        return false; // Or handle error as appropriate, perhaps true to prevent adding to invalid inventory
    }
    #endregion
    #region 1.2 Pre-condition Checks
    // No specific pre-conditions to check for this utility beyond parameter validation.
    #endregion

    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS
    // =========================================================================
    #region 2.1 Local Constants
    // Define the maximum capacity for the inventory.
    // This could be a global constant or passed as an argument for more flexibility.
    var MAX_CAPACITY = 10; // Example value, adjust as needed for your game's design.
    #endregion
    #region 2.2 Configuration from Parameters/Globals
    // No specific configurations derived from parameters or global settings for this utility.
    #endregion

    // =========================================================================
    // 3. INITIALIZATION & STATE SETUP
    // =========================================================================
    #region 3.1 One-Time Setup / State Variables
    // No specific initialization or state setup needed for this utility.
    #endregion

    // =========================================================================
    // 4. CORE LOGIC
    // =========================================================================
    #region 4.1 Main Behavior / Utility Logic
    // Calculate the total number of items currently in the inventory.
    var _total_items = 0;
    
    // Iterate over each key (item_id) in the inventory struct.
    // The value associated with each key is assumed to be the quantity of that item.
    // GameMaker's foreach loop is suitable here.
    // Note: This assumes item quantities are direct numerical values.
    // If items are structs themselves (e.g., { quantity: 5, durability: 100 }),
    // this logic would need to access the quantity field (e.g., _inventory[_key].quantity).
    // Based on GDD 3.4, pop inventory is `ds_map { item_id -> qty }`, which translates to struct { string_item_id: qty }
    // So, this direct summation is correct.
    foreach (var _item_id_key in _inventory) {
        // Ensure the value is a real number before adding, to prevent errors if inventory struct is malformed.
        if (is_real(_inventory[_item_id_key])) {
            _total_items += _inventory[_item_id_key];
        } else {
            show_debug_message("WARNING: scr_inventory_is_full() — Non-numeric quantity for item '" + string(_item_id_key) + "' in inventory.");
        }
    }

    // Return true if the total items meet or exceed the max capacity.
    return _total_items >= MAX_CAPACITY;
    #endregion

    // =========================================================================
    // 5. CLEANUP & RETURN
    // =========================================================================
    #region 5.1 Cleanup (if necessary)
    // No specific cleanup (e.g., freeing dynamic memory) is required for this function.
    #endregion
    #region 5.2 Return Value
    // The return is handled directly in the CORE LOGIC section (4.1) for this simple function
    // to avoid an extra step. The final result is `_total_items >= MAX_CAPACITY`.
    #endregion

    // =========================================================================
    // 6. DEBUG/PROFILING (Optional)
    // =========================================================================
    #region 6.1 Debug & Profile Hooks
    // No specific debug or profiling hooks needed for this utility.
    #endregion
}
