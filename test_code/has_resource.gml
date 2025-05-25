/// @description Checks if a subject has a certain amount of a resource in its inventory.
/// @param {object} subject - The object to check.


//some badly formatted function with probably bad syntax
//Purpose: pulls an objects enum from the database and then gets the amount as an int for that item and gets an inventory (or a struct that is tagged as "inventory")
//Comment: Pretty much an example id love to be able to have to limit the amount of scripts and code would look like this.
//Example (we dont need to impliment, just an example so you see how I want to get and set data for instances): I want to click on a button to craft a stone tool from the amount of resources a structure (Tool Hut) has available.

function has_resources(var subject, enum item, int amount)
{
    // Check if the subject is valid
    if (!is_object(subject)) {
        show_debug_message("ERROR: Subject is not a valid object.");
        return false;
    }

    // Check if the item is a valid enum
    if (!is_enum(item)) {
        show_debug_message("ERROR: Item is not a valid enum.");
        return false;
    }

    // Check if the amount is a valid integer
    if (!is_integer(amount) || amount <= 0) {
        show_debug_message("ERROR: Amount must be a positive integer.");
        return false;
    }

    // Check if the subject has the required resources
    var satisfies_requirements = true
    while(satisfies_requirements)
    {
            var item_data = get_data(item) //Bad example of getting the data of the item requested
    
    if(subject.contains(struct inventory)) //Really bad syntax, but its an example of checking if the subject has an inventory struct
    {
        var inventory = subject.inventory //set the inventory to the inventory struct
        if(inventory.exists()) //check if the inventory exists
        {
            if(inventory.contains(item)) //check if the inventory contains the item
            {
                var amount_in_inventory = inventory.getcount(item) //get the amount of the item in the inventory
                if(amount_in_inventory >= amount) //check if the amount in the inventory is greater than or equal to the amount requested
                {
                    satisfies_requirements = true //satisfies requirements
                }
                else
                {
                    show_debug_message($"Not enough of {item_data.name} in . Need: {amount} -- Has: {amount_in_inventory}")
                    satisfies_requirements = false //fails the check
                    break;
                }
            }
        }
    } else {
        show_debug_message($"{subject.name} does not have an inventory.")
        satisfies_requirements = false //fails the check
        break;
    }

    var inventory = subject.inventory //gets the inventory struct from a pop that contains it.

    if inventory.exists(){
        if inventory.contains(item){
            var amount_in_inventory = inventory.getcount(item)
            if(amount_in_inventory >= amount){
                satisfies_requirements = true
            } else {
                show_debug_message($"Not enough of {item_data.name} in . Need: {amount} -- Has: {amount_in_inventory}")
                satisfies_requirements = true
                break;
            }
        }
    }

    if(satisfies_requirements){
        show_debug_message($"{subject.name} has enough {item_data.name} in inventory.")
        return true
    } else {
        show_debug_message($"{subject.name} does not have enough {item_data.name} in inventory.")
        return false
    }
    
}

// Now we go back to the check to see if the player can craft a stone tool
// We check if the player has enough resources to craft a stone tool

function craft(enum item, int amount, var crafter) //gets the item to be crafted, the amount, and the instance crafting it.
{
    crafting_time = Values.Time.BASE_CRAFTING_TIME / (crafter.skills.CRAFTING / 2) // Some enum in the Pop data that has their skills and some logic to calculate how much time to take off based on a crafters skill level.
    crafting_countdown = crafting_time * room_speed // Convert seconds to frames
    
    // Check if the crafter is valid
    if (!is_object(crafter)) {
        show_debug_message("ERROR: Crafter is not a valid object.");
        return false;
    }
    // Check if the item is a valid enum
    if (!is_enum(item)) {
        show_debug_message("ERROR: Item is not a valid enum.");
        return false;
    }

    // Check if the amount is a valid integer
    if (!is_integer(amount) || amount <= 0) {
        show_debug_message("ERROR: Amount must be a positive integer.");
        return false;
    }

    // Check if the crafter or structure has enough resources to craft the item
    var instance = get_instance(); // Get the current instance (player or structure)
    if (instance == noone) {
        show_debug_message("ERROR: No instance found.");
        return false;
    }

    if(crafter.traits.contains("GIFTED_CRAFTER")) // Check if the crafter has the crafting trait
    {
        crafting_time = crafting_time * 0.5 // If the crafter has the crafting trait, reduce the crafting time by 50%
    }
    if(crafter.traits.contains("SLOW_CRAFTER")) // Check if the crafter has the crafting trait
    {
        crafting_time = crafting_time * 1.5 // If the crafter has the crafting trait, increase the crafting time by 50%
    }
    if(crafter.traits.contains("FAST_CRAFTER")) // Check if the crafter has the crafting trait
    {
        crafting_time = crafting_time * 0.75 // If the crafter has the crafting trait, reduce the crafting time by 25%
    }

    if (has_resources(instance, Resource.STONE, 5) && has_resources(instance, Resource.STICK, 2)) {
        var crafted_axe = get_data(Resource.STONE_AXE, 1); // Add the crafted item to the inventory

        //Now check to see if the crafter has any traits that affect crafting quality or applies special abilities
        //This might also be checked somewhere else, but this is just an example of how to do it.
        if(crafter.traits.contains("BEAUTIFUL_CRAFTER")) // Check if the crafter has the crafting trait
        {
            value = value * 1.25 // If the crafter has the crafting trait, increase the crafting quality by 25%
        }
        if(crafter.traits.contains("SLOPPY_CRAFTER")) // Check if the crafter has the crafting trait
        {
            value = value * 0.75 // If the crafter has the crafting trait, decrease the crafting quality by 25%
        }
        if(crafter.traits.contains("LUCKY_CRAFTER")) // Check if the crafter has the crafting trait
        {
            crafted_axe.Traits.add("LUCKY"); // If the crafter has the crafting trait, increase the crafting quality by 50%
        }
        if(crafter.traits.contains("UNLUCKY_CRAFTER")) // Check if the crafter has the crafting trait
        {
            //We could later set up a "dice rolling system" for these checks that have the skills influence the outcome
            random_value = irandom_range(1, 20); // Get a random value between 1 and 20
            if(random_value <= 10) // If the random value is less than or equal to 30
            {
                crafted_axe.Traits.add("UNLUCKY"); // If the crafter has the crafting trait, increase the crafting quality by 50%
            }
        }

        subject.inventory.remove(Resource.STONE, 5); // Remove the resources from the inventory
        subject.inventory.remove(Resource.STICK, 2); // Remove the resources from the inventory
        

        alarm[0] = crafting_countdown; // Set the alarm for crafting time
        alarm[0].start(); // Wait while the crafting process happens.
        instance.inventory.add(crafted_axe); // Add the crafted item to the inventory
        show_debug_message($"Crafting {crafted_axe.name} for {crafter.name}.");
    } else {
        // Code to execute if resources are not available
    }
}
// This is a simple example of how to use the has_resources function