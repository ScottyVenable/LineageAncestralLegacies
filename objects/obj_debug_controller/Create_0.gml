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
            global.Debug.Enabled = true; // Master switch for the entire debug system, true by default
            enum DebugStatus = enum("DISABLED", "FULL", "ERROR_ONLY", "PAUSED", "RELEASE"); // Define an enum for debug status. DISABLED = no debug messages, FULL = all messages, ERROR_ONLY = only error messages, PAUSED = temporarily paused, RELEASE = production ready mode.
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
#endregion

// ----------------------------------------------------------------
//                      CONDITIONAL LOGIC
// ----------------------------------------------------------------

#region 2. CONDITIONAL LOGIC
    // This section ensures that the global Debug object and its properties are initialized
    // and that master switches correctly propagate their state to more specific flags.

    #region 2.1 Pre-conditions
        // Check if the global Debug object exists and has the Logging property
        if (!variable_global_exists("Debug") || !is_struct(global.Debug)) {
            // If not, initialize it to prevent errors in other scripts
            global.Debug = {};
        }
        
        // Ensure sub-structs exist, initializing them if necessary
        var _debug_categories = [
            "Logging", "Rendering", "Entities", "Errors", "DevTools", 
            "ErrorHandling", "UI", "AI", "Inventory", "Pathfinding", "Misc"
        ];

        for (var i = 0; i < array_length(_debug_categories); i++) {
            var cat_name = _debug_categories[i];
            if (!variable_struct_exists(global.Debug, cat_name) || !is_struct(global.Debug[@ cat_name])) {
                global.Debug[@ cat_name] = {};
            }
            // Ensure the .Enabled flag exists for categories that should have it
            // Logging has AllEnabled. Errors and ErrorHandling have their own .Enabled flags directly under global.Debug.CategoryName.Enabled
            // For Errors, we also need to ensure Messages sub-struct is initialized.
            if (cat_name == "Errors") {
                if (!variable_struct_exists(global.Debug.Errors, "Enabled")) {
                    global.Debug.Errors.Enabled = true; // Default to true
                }
                if (!variable_struct_exists(global.Debug.Errors, "Messages") || !is_struct(global.Debug.Errors.Messages)) {
                    global.Debug.Errors.Messages = {}; // Initialize if missing
                }
            } else if (cat_name != "Logging" && cat_name != "ErrorHandling") { 
                 if (!variable_struct_exists(global.Debug[@ cat_name], "Enabled")) {
                    global.Debug[@ cat_name].Enabled = true; // Default to true
                 }
            }
        }

        if (!variable_struct_exists(global.Debug, "Enabled")) {
            global.Debug.Enabled = true; // Default to true if not set
        }
        if (!variable_struct_exists(global.Debug, "Status")) {
             // Define an enum for debug status if not already defined (e.g. if this runs before the main init)
            enum DebugStatusLocal = enum("DISABLED", "FULL", "ERROR_ONLY", "PAUSED", "RELEASE");
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
        if (!global.Debug.Enabled) {
            global.Debug.Logging.AllEnabled = false;
            
            // Also disable all other main category .Enabled flags
            if (variable_struct_exists(global.Debug, "Rendering") && variable_struct_exists(global.Debug.Rendering, "Enabled")) global.Debug.Rendering.Enabled = false;
            if (variable_struct_exists(global.Debug, "Entities") && variable_struct_exists(global.Debug.Entities, "Enabled")) global.Debug.Entities.Enabled = false;
            if (variable_struct_exists(global.Debug, "Errors") && variable_struct_exists(global.Debug.Errors, "Enabled")) global.Debug.Errors.Enabled = false; // If Debug.Enabled is false, even error specific visuals go.
            if (variable_struct_exists(global.Debug, "DevTools") && variable_struct_exists(global.Debug.DevTools, "Enabled")) global.Debug.DevTools.Enabled = false;
            if (variable_struct_exists(global.Debug, "ErrorHandling") && variable_struct_exists(global.Debug.ErrorHandling, "Enabled")) global.Debug.ErrorHandling.Enabled = false;
            if (variable_struct_exists(global.Debug, "UI") && variable_struct_exists(global.Debug.UI, "Enabled")) global.Debug.UI.Enabled = false;
            if (variable_struct_exists(global.Debug, "AI") && variable_struct_exists(global.Debug.AI, "Enabled")) global.Debug.AI.Enabled = false;
            if (variable_struct_exists(global.Debug, "Inventory") && variable_struct_exists(global.Debug.Inventory, "Enabled")) global.Debug.Inventory.Enabled = false;
            if (variable_struct_exists(global.Debug, "Pathfinding") && variable_struct_exists(global.Debug.Pathfinding, "Enabled")) global.Debug.Pathfinding.Enabled = false;
            if (variable_struct_exists(global.Debug, "Misc") && variable_struct_exists(global.Debug.Misc, "Enabled")) global.Debug.Misc.Enabled = false;
        }

        // If the master logging switch (global.Debug.Logging.AllEnabled) is false,
        // disable all individual logging categories.
        // Otherwise, they retain the values set in the "Boolean Flags" section.
        if (!global.Debug.Logging.AllEnabled) {
            if (variable_struct_exists(global.Debug.Logging, "WorldgenEnabled")) global.Debug.Logging.WorldgenEnabled = false;
            if (variable_struct_exists(global.Debug.Logging, "PopsEnabled")) global.Debug.Logging.PopsEnabled = false;
            if (variable_struct_exists(global.Debug.Logging, "EntitiesEnabled")) global.Debug.Logging.EntitiesEnabled = false;
            if (variable_struct_exists(global.Debug.Logging, "UIEnabled")) global.Debug.Logging.UIEnabled = false;
            if (variable_struct_exists(global.Debug.Logging, "AIEnabled")) global.Debug.Logging.AIEnabled = false;
            if (variable_struct_exists(global.Debug.Logging, "InventoryEnabled")) global.Debug.Logging.InventoryEnabled = false;
            
            // Add any other specific categories here to ensure they are also disabled.
            // e.g., if (variable_struct_exists(global.Debug.Logging, "PathfindingEnabled")) global.Debug.Logging.PathfindingEnabled = false;
        }
    #endregion
#endregion


