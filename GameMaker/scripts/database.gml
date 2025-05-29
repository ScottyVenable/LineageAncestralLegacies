// ...existing code defining the db map/struct...

// Wood entry
db[ITEM_WOOD] = {
    // ...existing properties...
    display_name: "Wood",
    weight_kg:     1,
    tags:          ["resource"]        // Mark wood as a resource
};

// Stone entry
db[ITEM_STONE] = {
    // ...existing properties...
    display_name: "Stone",
    weight_kg:     2,
    tags:          ["resource"]        // Mark stone as a resource
};

// Berry entry
db[ITEM_BERRY] = {
    // ...existing properties...
    display_name:     "Berry",
    weight_per_unit:  0.1,
    tags:             ["food","resource"]  // Berries are both food & resource
};

// ...rest of database definitions...
