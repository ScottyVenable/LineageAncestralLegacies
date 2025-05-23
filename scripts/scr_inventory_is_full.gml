/// scr_inventory_is_full.gml
///
/// Purpose:
///   Checks if the given inventory struct is full based on a predefined capacity.
///
/// Metadata:
///   Summary:       Determines if an inventory has reached its maximum capacity.
///   Parameters:    _inventory : struct — The inventory to check.
///   Returns:       boolean — True if the inventory is full, false otherwise.
///   Tags:          [utility][inventory][capacity]
///   Version:       1.0 - 2025-05-22
///   Dependencies:  None

function scr_inventory_is_full(_inventory) {
    // Define the maximum capacity for the inventory
    var max_capacity = 10; // Example value, adjust as needed

    // Calculate the total number of items in the inventory
    var total_items = 0;
    foreach (var _key in _inventory) {
        total_items += _inventory[_key];
    }

    // Return true if the total items exceed or equal the max capacity
    return total_items >= max_capacity;
}
