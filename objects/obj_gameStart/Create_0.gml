//
// GameStart Create Event
// This event is triggered once when the game starts.
// It's the ideal place to initialize game-wide settings, load data,
// and set up the initial game state.

// Initialize the debug message system.
// This should be one of the first things to run.
debug_message_init(true); // true by default, can be changed later or loaded from a config

// --- Initialize Debug Console Global Variables ---
// This ensures the debug console starts in a known state.
// global.Debug.Console.Visible will be initialized by obj_dev_console_controller
// --- End Debug Console Initialization ---

// Log that the game has started.
// Uses the new debug_message system, so it will only show if debug messages are enabled.
debug_message("obj_gameStart: Create event started.");

// Initialize global game data structure
global.GameData = {};
debug_message("Global.GameData initialized.");

// Load all external game data (JSON files)
// The path provided is relative to the "Included Files" directory.
// This function will handle copying to save directory if needed and loading.
debug_message("Attempting to load all external game data...");
scr_load_external_data_all("gamedata\\core"); // Ensure backslashes for Windows paths if needed by GMS
debug_message("External game data loading process initiated.");

// Initialize other game systems as needed
// For example, initialize the database or other core systems that rely on loaded data.
// Ensure these are called *after* data is loaded if they depend on it.
debug_message("Initializing database...");
scr_database_init();
debug_message("Database initialized.");

// Example: Transition to the first game room or main menu
// room_goto(rm_main_menu);
debug_message("obj_gameStart: Create event finished. Game setup complete.");

// Instead of rm_test_environment, use a real room or comment out for now to avoid errors.
// Example: if (room_exists(World)) { ... } else { ... }
// If you don't have a test room, comment out this block:
// if (room_exists(rm_test_environment)) {
//     debug_message("Transitioning to rm_test_environment.");
//     room_goto(rm_test_environment);
// } else {
//     debug_message("rm_test_environment not found. Staying in initial room or ending game (if this is the only room).");
//     // Optionally, show an error or go to a default room like a main menu
//     // For now, it will just stay in the current room if rm_test_environment doesn't exist.
// }

// NOTE: If you want obj_controller to run before this, place obj_controller ABOVE obj_gameStart in the Room Editor's instance order.
// This ensures all controller variables and systems are initialized before game start logic runs.
