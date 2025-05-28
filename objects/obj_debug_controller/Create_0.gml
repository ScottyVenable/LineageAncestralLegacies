/// obj_debug_controller – Create Event
///
/// Purpose:
///    Initializes the debug controller object, setting up any necessary variables
///    or states for managing debug output, including the message queue.
///

// ----------------------------------------------------------------
//                        GLOBAL VARIABLES
// ----------------------------------------------------------------
#region 1. GLOBAL VARIABLES
    
    #region 1.1 DEBUG LOGGING
    /// This section initializes variables related to debug logging.

        #region 1.1.1 Initialization
            // Initialize the global Debug object and its Logging sub-object.
            // This is done to ensure that the debug logging system is ready to use.
            global.Debug = {};
            global.Debug.Logging = {};
            global.Debug.Rendering = {};
            global.Debug.Entities = {};
            global.Debug.Errors = {};
            global.Debug.Console = {};
            global.Debug.Enabled = true; // Master switch for the entire debug system, true by default
            enum DebugStatus {DISABLED, FULL, ERROR_ONLY, PAUSED, RELEASE}; // Define an enum for debug status. DISABLED = no debug messages, FULL = all messages, ERROR_ONLY = only error messages, PAUSED = temporarily paused, RELEASE = production ready mode.
            global.Debug.Status = DebugStatus.FULL;

            // Initialize the queue for debug messages
            // Messages will be added to this list by queue_debug_message()
            // and processed by this object in its Step Event.
            global.debug_message_queue = ds_list_create();
        #endregion
        #region 1.2.2 Boolean Flags
        /// These flags control various debug features globally.

        global.Debug.Logging.AllEnabled = true; // Master switch: Enable debug messages for all categories by default
        
        // Per-category flags
        global.Debug.Logging.WorldgenEnabled = true; // Enable world generation debugging
        global.Debug.Logging.PopsEnabled = true;     // Enable population debugging
        global.Debug.Logging.EntitiesEnabled = true; // Enable general entity debugging
        global.Debug.Logging.UIEnabled = true;       // Enable UI debugging
        global.Debug.Logging.AIEnabled = true;       // Enable AI debugging
        global.Debug.Logging.InventoryEnabled = true; // Enable Inventory debugging
        
        // Add more categories here as needed, e.g.:
        // global.Debug.Logging.PathfindingEnabled = false;
        // global.Debug.Logging.CombatEnabled = false;
        
        #endregion
    #endregion
    
    #region 1.2 ENTITY DEBUGGING
    /// This section initializes variables related to entity debugging.

    global.Debug.Entities.Enabled = true; // Master switch for entity debugging features
    global.Debug.Entities.List = ds_list_create(); // List to hold entities for debugging
    global.Debug.Entities.ViewPerception = true; // Enable viewing entity perception by default
    global.Debug.Entities.ViewActiveState = true; // Enable viewing entity active state by default
    global.Debug.Entities.ViewInventoryDebug = true; // Enable viewing entity inventory debugging by default

    global.Debug.Entities.DebugRelationships = true; // Enable viewing entity relationships by default

    #endregion

    #region 1.3 RENDER DEBUGGING
    /// This section initializes variables related to rendering debugging.
    global.Debug.Rendering = {};
    global.Debug.Rendering.Enabled = true; // Master switch for rendering debug features
    global.Debug.Rendering.ShowBoundingBoxes = false; // Draw bounding boxes for objects
    global.Debug.Rendering.ShowCollisionMasks = false; // Draw precise collision masks
    global.Debug.Rendering.ShowPaths = false;         // Visualize AI or movement paths
    global.Debug.Rendering.ShowGrids = false;          // Display debugging grids (e.g., world grid, pathfinding grid)
    global.Debug.Rendering.DisableLighting = false;    // Turn off lighting effects to see base sprites
    global.Debug.Rendering.ShowFPS = true;           // Display FPS counter (GameMaker has one, but custom can be useful)
    #endregion

    #region 1.4 ERROR DEBUGGING
        /// This section initializes variables related to error visualization and logging.
        /// Note: Logging of errors to the console is handled by the Logging category and DebugStatus.
        global.Debug.Errors = {};
        global.Debug.Errors.Enabled = true; // Master switch for error debugging features
        global.Debug.Errors.ShowErrorLocations = false; // e.g., draw a marker in-game where a script error occurred
        global.Debug.Errors.LogToExternalFile = false; // Enable/disable verbose error logging to a separate file
        global.Debug.Errors.ShowAssertions = true; // Display assertion failures if using an assertion system

        global.Debug.Errors.Messages = {}; // Struct to hold predefined error messages
        global.Debug.Errors.Messages.MissingCriticalFile = "CRITICAL ERROR: A required data file is missing. The game cannot continue.";
        global.Debug.Errors.Messages.InvalidArgument = "ERROR: Invalid argument provided to function. Check call stack.";
        global.Debug.Errors.Messages.AssertionFailed = "ASSERTION FAILED: A critical game logic assertion failed.";
        global.Debug.Errors.Messages.ResourceNotFound = "ERROR: A required game resource (sprite, sound, object, etc.) could not be found.";
        global.Debug.Errors.Messages.InvalidState = "ERROR: An object or system is in an unexpected or invalid state.";
        global.Debug.Errors.Messages.NetworkError = "NETWORK ERROR: A problem occurred with network communication.";
        global.Debug.Errors.Messages.SaveLoadError = "SAVE/LOAD ERROR: Failed to save or load game data.";
        global.Debug.Errors.Messages.InitializationFailure = "INITIALIZATION FAILURE: A core system failed to initialize.";
        // Add more specific error messages as needed, e.g.:
        // global.Debug.Errors.Messages.InventoryFull = "Inventory is full. Cannot add item.";
        // global.Debug.Errors.Messages.InvalidPopId = "Invalid Pop ID referenced.";
    #endregion
    
    #region 1.5 IN-GAME DEVELOPMENT TOOLS
    // This section initializes variables related to in-game development tools.
        global.Debug.DevTools = {};
        global.Debug.DevTools.Enabled = false; // Master switch for in-game dev tools

        #region 1.5.1 Dev Console
        /// This section initializes variables related to the in-game development console.
        global.Debug.DevTools.DevConsoleKey = vk_f12; // Default key to toggle dev console
        global.Debug.DevTools.DevConsoleVisible = false; // Track visibility of the dev console
        #endregion

        #region 1.5.2 Developer Quick Menu
        /// This section initializes variables related to the in-game developer quick menu.
        global.Debug.DevTools.DevQuickMenuKey = vk_f11; // Default key to toggle dev quick menu
        global.Debug.DevTools.DevQuickMenuVisible = false; // Track visibility of the dev quick menu
        #endregion

    #endregion

    #region 1.6 ERROR HANDLING
        /// This section initializes variables related to how the game handles errors at runtime.
        global.Debug.ErrorHandling = {};
        global.Debug.ErrorHandling.Enabled = true; // Master switch for error handling behaviors
        global.Debug.ErrorHandling.StrictMode = false; // If true, game might halt on minor issues; if false, tries to continue
        global.Debug.ErrorHandling.GracefulCatch = true; // Attempt to catch errors gracefully and report, rather than crash
    #endregion

    #region 1.7 UI DEBUGGING
        /// This section initializes variables related to UI debugging.
        global.Debug.UI = {};
        global.Debug.UI.Enabled = true; // Master switch for UI debugging features
        global.Debug.UI.ShowElementBounds = false; // Draw bounding boxes around UI elements
        global.Debug.UI.HighlightFocusedElement = false; // Visually highlight the currently focused UI element
        global.Debug.UI.ShowMouseCoordinates = false; // Display mouse coordinates (screen and GUI layer)
        global.Debug.UI.LogNavigation = false; // Log UI navigation events
    #endregion
    
    #region 1.8 AI DEBUGGING
    /// This section initializes variables related to AI debugging.
    global.Debug.AI = {};
    global.Debug.AI.Enabled = true; // Master switch for AI debugging features
    global.Debug.AI.ShowAgentStates = false; // Display the current state of AI agents (e.g., text above them)
    global.Debug.AI.ShowPerceptionRanges = false; // Visualize AI sight, hearing, or other perception ranges
    global.Debug.AI.LogDecisionMaking = false; // More verbose logging for AI choices (can be performance heavy)
    global.Debug.AI.ShowTargetInfo = false; // Display what an AI is currently targeting or pathing towards
    #endregion

    #region 1.9 INVENTORY DEBUGGING
    /// This section initializes variables related to inventory debugging.
    global.Debug.Inventory = {};
    global.Debug.Inventory.Enabled = true; // Master switch for inventory debugging features
    global.Debug.Inventory.LogTransactions = false; // Log when items are added, removed, or transferred
    global.Debug.Inventory.ShowFullnessIndicators = false; // Visual feedback on inventory capacity (e.g., on containers)
    global.Debug.Inventory.ValidateItemDataOnLoad = false; // Perform deeper checks on item data integrity when loaded
    #endregion

    #region 1.10 PATHFINDING DEBUGGING
    /// This section initializes variables related to pathfinding debugging.
    global.Debug.Pathfinding = {};
    global.Debug.Pathfinding.Enabled = true; // Master switch for pathfinding debug features
    global.Debug.Pathfinding.ShowPathNodes = false; // Visualize the nodes of calculated paths
    global.Debug.Pathfinding.ShowPathfindingGrid = false; // If using a grid, display it
    global.Debug.Pathfinding.LogFailures = true; // Log detailed information when pathfinding fails to find a path
    global.Debug.Pathfinding.HighlightCurrentPathUser = false; // Highlight entity currently using a debug-displayed path
    #endregion

    #region 1.11 MISCELLANEOUS DEBUGGING
    /// This section initializes variables related to miscellaneous debugging.
    global.Debug.Misc = {};
    global.Debug.Misc.Enabled = true; // Master switch for miscellaneous debug features
    global.Debug.Misc.ShowTimers = false; // Display any active custom timers
    global.Debug.Misc.LogNetworkMessages = false; // For multiplayer, log network traffic (if applicable)
    #endregion

    #region 1.12 DEBUG CONSOLE
    /// This section initializes variables related to the debug console.
    global.Debug.Console.Enabled = false; // Master switch for the debug console
    global.Debug.Console.Visible = false; // Track visibility of the debug console
    global.Debug.Console.Messages = []; // Array to hold messages for the debug console

    global.Debug.Console.InputColor = c_black
    global.Debug.Console.OutputColor = c_blue
    global.Debug.Console.draw_messages = function(messages_array) {
        // This function will handle drawing the messages in the console.
        // It should be defined in the obj_dev_console object.
        // For now, we assume it exists and is responsible for rendering messages.
        if (instance_exists(obj_dev_console)) {
            obj_dev_console.draw_messages(messages_array || global.Debug.Console.Messages); // Draw the messages from the provided array or the default console messages
        } else {
            show_debug_message("DEBUG_SYSTEM: obj_dev_console instance does not exist. Cannot draw messages.");
        }
    };
    global.Debug.Console.submitCommand = function(message) {
        // Default behavior: Show a debug message and reset the input field.
        show_debug_message("DEBUG_CONSOLE: Command submitted: " + message);
        
        // Here, add the message to the console and draw it.
        global.Debug.Console.Messages[array_length(global.Debug.Console.Messages)] = "> " + message; // Add the command to the console messages
        global.Debug.Console.draw_messages(); // Call a method to redraw the console messages
        
        // Reset the input box for the next command
        global.Debug.Console.InputBox.text = ">"; // Reset text to the prompt
        global.Debug.Console.InputBox.cursor_pos = string_length(global.Debug.Console.InputBox.text); // Place cursor after the prompt
        global.Debug.Console.InputBox.selection_start = global.Debug.Console.InputBox.cursor_pos; // Clear any selection
        global.Debug.Console.InputBox.selection_end = global.Debug.Console.InputBox.cursor_pos;

    };
    #endregion
    
    #endregion


#endregion

// ----------------------------------------------------------------
//                      CONDITIONAL LOGIC
// ----------------------------------------------------------------

#region 2. CONDITIONAL LOGIC
    // This section ensures that the global Debug object and its properties are initialized
    // and that master switches correctly propagate their state to more specific flags.

    #region 2.1 Pre-conditions
        // Check if the global Debug object exists and has the Logging property
        show_debug_message("DEBUG_SYSTEM: Entering Pre-conditions. Checking global.Debug...");
        if (variable_global_exists("Debug")) {
            show_debug_message("DEBUG_SYSTEM: global.Debug exists. Type: " + typeof(global.Debug) + ", IsStruct: " + string(is_struct(global.Debug)));
        } else {
            show_debug_message("DEBUG_SYSTEM: global.Debug does NOT exist prior to check.");
        }

        if (!variable_global_exists("Debug") || !is_struct(global.Debug)) {
            show_debug_message("DEBUG_SYSTEM: Condition was TRUE. global.Debug was not a struct or did not exist. Initializing global.Debug = {}.");
            global.Debug = {};
        } else {
            show_debug_message("DEBUG_SYSTEM: Condition was FALSE. global.Debug existed and was a struct.");
        }
        show_debug_message("DEBUG_SYSTEM: After check. IsStruct(global.Debug): " + string(is_struct(global.Debug)));
        
        // Ensure sub-structs exist, initializing them if necessary
        var _debug_categories = [
            "Logging", "Rendering", "Entities", "Errors", "DevTools", 
            "ErrorHandling", "UI", "AI", "Inventory", "Pathfinding", "Misc"
        ];

        for (var i = 0; i < array_length(_debug_categories); i++) {
            var cat_name = _debug_categories[i];
            var _category_struct; // Will hold the struct for the current category, e.g., global.Debug.Logging

            // Check if the category (e.g., "Logging") exists as a key in global.Debug
            if (!variable_struct_exists(global.Debug, cat_name)) {
                // If the key itself doesn't exist, create the struct.
                // This handles categories that might not have been pre-initialized earlier.
                show_debug_message("DEBUG_SYSTEM: Key '" + cat_name + "' does not exist in global.Debug. Initializing global.Debug[$ '" + cat_name + "'] = {}.");
                global.Debug[$ cat_name] = {};
                _category_struct = global.Debug[$ cat_name];
            } else {
                // The key exists. Now, get the member associated with that key.
                var _member = variable_struct_get(global.Debug, cat_name);
                
                // Check if the retrieved member is actually a struct.
                // It could exist but be something else if code elsewhere accidentally overwrote it.
                if (!is_struct(_member)) {
                    show_debug_message("DEBUG_SYSTEM: Member global.Debug." + cat_name + " exists but is not a struct (Type: " + typeof(_member) + "). Re-initializing to {}.");
                    global.Debug[$ cat_name] = {}; // Re-initialize as an empty struct
                    _category_struct = global.Debug[$ cat_name]; // Get the newly created struct
                } else {
                    // The member exists and is already a struct. Use it.
                    // show_debug_message("DEBUG_SYSTEM: Member global.Debug." + cat_name + " exists and is a struct. Using existing.");
                    _category_struct = _member;
                }
            }
            
            // At this point, _category_struct is guaranteed to be the struct for the current category (e.g., global.Debug.Logging)

            // Ensure the .Enabled flag exists for categories that should have it.
            // _category_struct refers to the specific category struct, e.g., global.Debug.Errors, global.Debug.Rendering.
            if (cat_name == "Errors") {
                // For global.Debug.Errors (which is _category_struct here)
                if (!variable_struct_exists(_category_struct, "Enabled")) {
                    show_debug_message("DEBUG_SYSTEM: global.Debug.Errors.Enabled not found. Setting to true.");
                    _category_struct.Enabled = true; 
                }
                if (!variable_struct_exists(_category_struct, "Messages") || !is_struct(_category_struct.Messages)) {
                    show_debug_message("DEBUG_SYSTEM: global.Debug.Errors.Messages not found or not a struct. Initializing to {}.");
                    _category_struct.Messages = {}; 
                }
            } else if (cat_name == "ErrorHandling") {
                // For global.Debug.ErrorHandling (which is _category_struct here)
                if (!variable_struct_exists(_category_struct, "Enabled")) {
                    show_debug_message("DEBUG_SYSTEM: global.Debug.ErrorHandling.Enabled not found. Setting to true.");
                    _category_struct.Enabled = true; 
                }
            } else if (cat_name != "Logging") { 
                 // For other categories (e.g., Rendering, Entities, UI, AI, etc., but NOT Logging)
                 // their .Enabled flag is directly within their struct (e.g., global.Debug.Rendering.Enabled).
                 // _category_struct here is global.Debug.Rendering, global.Debug.Entities, etc.
                 if (!variable_struct_exists(_category_struct, "Enabled")) {
                    show_debug_message("DEBUG_SYSTEM: global.Debug." + cat_name + ".Enabled not found. Setting to true.");
                    _category_struct.Enabled = true; 
                 }
            }
            // Note: global.Debug.Logging.AllEnabled is the master switch for logging messages
            // and is assumed to be initialized. Individual log sub-categories like WorldgenEnabled
            // are also under global.Debug.Logging.
        }

        if (!variable_struct_exists(global.Debug, "Enabled")) {
            global.Debug.Enabled = true; // Default to true if not set
        }
        if (!variable_struct_exists(global.Debug, "Status")) {
             // Define an enum for debug status if not already defined (e.g. if this runs before the main init)
            enum DebugStatusLocal {DISABLED, FULL, ERROR_ONLY, PAUSED, RELEASE};
            global.Debug.Status = DebugStatusLocal.FULL;
        }

        // Initialize the debug message queue if it doesn't exist
        if (!variable_global_exists("debug_message_queue") || !ds_exists(global.debug_message_queue, ds_type_list)) {
            global.debug_message_queue = ds_list_create();
        }
        
        // Ensure AllEnabled exists in Logging, default to true if not.
        if(!variable_struct_exists(global.Debug.Logging, "AllEnabled")) {
            global.Debug.Logging.AllEnabled = true;
        }
    #endregion

    #region 2.2 Master Switch Application
        // Apply DebugStatus effects first, as it's the highest level control.
        if (global.Debug.Status == DebugStatus.DISABLED || global.Debug.Status == DebugStatus.RELEASE) {
            global.Debug.Enabled = false;       // Turn off the entire debug system functionality.
            global.Debug.Logging.AllEnabled = false; // Specifically turn off all logging.
        } else if (global.Debug.Status == DebugStatus.ERROR_ONLY) {
            // For ERROR_ONLY, general categorized logging is off.
            global.Debug.Logging.AllEnabled = false;
            // Errors themselves might still be shown via show_error or a direct error logging mechanism,
            // not necessarily through the categorized queue_debug_message system.
            // You might enable global.Debug.Errors.Enabled here if it controls specific error visualizations.
            if (variable_struct_exists(global.Debug, "Errors") && variable_struct_exists(global.Debug.Errors, "Enabled")) {
                global.Debug.Errors.Enabled = true; 
            }
        }
        // For FULL or PAUSED, global.Debug.Enabled and global.Debug.Logging.AllEnabled retain their values set above or by default,
        // allowing for more granular control below or direct manipulation.

        // If the overall debug system (global.Debug.Enabled) is off, ensure all logging AND category .Enabled flags are also off.


        // If the master logging switch (global.Debug.Logging.AllEnabled) is false,
        // disable all individual logging categories.
        // Otherwise, they retain the values set in the "Boolean Flags" section.
    #endregion
#endregion


