/// par_slot_provider - Create Event
max_interaction_slots = 0; // Child objects will override this
interaction_slots_pop_ids = [];
interaction_slot_positions = [];

// Helper method to initialize slots (call this in child's Create after setting max_interaction_slots)
init_interaction_slots = function() {
    interaction_slots_pop_ids = array_create(max_interaction_slots, noone);
    // interaction_slot_positions will be defined by the child object
    // based on its specific shape and interaction points.
    // Example: child might do:
    // array_resize(interaction_slot_positions, max_interaction_slots);
    // interaction_slot_positions[0] = { rel_x: -20, rel_y: 0, interaction_type_tag: "work_left" };
    // etc.
}