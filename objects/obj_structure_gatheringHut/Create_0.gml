/// obj_structure_gatheringHut – Create Event
///
/// Purpose:
///    Initializes the gathering hut's drop-off slots for hauling pops.
///    Each slot represents a unique position where a pop can deliver resources, preventing traffic jams.
///
/// Metadata:
///    Summary:         Sets up drop-off slots for hauling pops.
///    Usage:           obj_structure_gatheringHut Create Event.
///    Parameters:      none
///    Returns:         void
///    Tags:            [structure][gathering_hut][hauling][slot_provider]
///    Version:         1.0 - 2025-05-22
///    Dependencies:    None (slot logic is self-contained)

// =========================================================================
// 1. DROP-OFF SLOT SETUP
// =========================================================================
#region 1.1 Drop-off Slot Positions
max_dropoff_slots = 4; // You can adjust this for more/less traffic
// Array of slot structs: {rel_x, rel_y, claimed_by}
dropoff_slots = array_create(max_dropoff_slots);
var slot_radius = 32; // Distance from hut center
for (var i = 0; i < max_dropoff_slots; i++) {
    var angle = i * (360 / max_dropoff_slots);
    dropoff_slots[i] = {
        rel_x: lengthdir_x(slot_radius, angle),
        rel_y: lengthdir_y(slot_radius, angle),
        claimed_by: noone // Will be set to pop id when claimed
    };
}
#endregion

// =========================================================================
// 2. DEBUG LOG
// =========================================================================
#region 2.1 Debug Log
// Log slot positions for learning/debugging
for (var i = 0; i < max_dropoff_slots; i++) {
    var slot = dropoff_slots[i];
    debug_log($"Gathering Hut slot {i}: rel_x={slot.rel_x}, rel_y={slot.rel_y}", "obj_structure_gatheringHut:Create", "cyan");
}
#endregion
