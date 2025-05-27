/// obj_gathering_hut
///
/// Purpose:
///   Represents a gathering hut building where pops can drop off resources.
///
/// Metadata:
///   Summary: Gathering hut for resource drop-off.
///   Usage: Placed in the room as an instance of obj_gathering_hut.
///   Parameters: None
///   Returns: void (interacts with pops directly)
///   Tags: [building][gathering][resource][dropoff]
///   Version: 1.0 — 2025-07-28
///   Dependencies: None
///   Created: 2023
///   Modified: 2025-07-28

// =========================================================================
// 0. INITIALIZATION
// =========================================================================
#region 0.1 Create Event
// Ensure the hut exposes a clear drop-off point for your hauling logic.
is_stockpile = true;                       // Flag as a valid dropoff target
accepted_item_tags = ["resource"];         // Only accept resources
dropoff_x = x;                             // Define exact dropoff coordinates
dropoff_y = y;
#endregion

// =========================================================================
// 1. INTERACTION LOGIC (e.g., for pops to deposit resources)
// =========================================================================
#region 1.1 Deposit Resource Event (Triggered by pops)
/// Event called by pops to deposit resources into the hut.

// Parameters:
///   item_id_enum : enum — The item type being deposited.
///   quantity : int — The amount of the item being deposited.
// Returns: bool — Success or failure of the deposit operation.

function deposit_resource(item_id_enum, quantity) {
    // Check if the item is accepted by this stockpile
    if (!array_contains(accepted_item_tags, get_item_data(item_id_enum, "tag"))) {
        return false; // Item type not accepted here
    }

    // Perform the deposit (e.g., increase the stockpile's resource count)
    // This is a placeholder; implementation depends on your resource management
    // For example: global.resource_stockpile[item_id_enum] += quantity;

    // Show feedback or update UI if necessary
    // For example: scr_ui_showDropoffText("Deposited " + string(quantity) + "x " + string(item_id_enum), 3);

    return true;
}
#endregion

// =========================================================================
// 2. SPRITE & ANIMATION (if applicable)
// =========================================================================
#region 2.1 Sprite Assignment
/// Assigns the appropriate sprite based on the hut's state or contents.

// Parameters: None
// Returns: void

function update_sprite() {
    // Example: Change sprite if hut is empty or full
    // if (global.resource_stockpile[item_id_enum] <= 0) {
    //     sprite_index = spr_hut_empty;
    // } else {
    //     sprite_index = spr_hut_full;
    // }
}
#endregion

// =========================================================================
// 3. CLEANUP & DESTRUCTION (if applicable)
// =========================================================================
#region 3.1 Destroy Event
/// Cleanup when the hut is destroyed (e.g., remove from stockpile, update UI).

function obj_gathering_hut_destroy() {
    // Example: Remove all resources from the stockpile
    // global.resource_stockpile[item_id_enum] -= quantity;
}
#endregion