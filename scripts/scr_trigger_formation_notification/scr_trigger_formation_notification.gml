/// scr_trigger_formation_notification.gml
///
/// Purpose:
///    Sets up the global variables to display a formation change notification message
///    at the top of the screen. The message will appear fully visible, stay for a
///    defined duration, and then fade out.
///
/// Metadata:
///    Summary:       Activates and configures the formation notification display.
///    Usage:         Call this script whenever global.current_formation_type changes
///                   and a visual notification is desired.
///                   e.g., scr_trigger_formation_notification("Formation: Line Horizontal");
///    Parameters:
///      notification_string : string   — The full text string to be displayed.
///    Returns:       void
///    Tags:          [ui][notification][feedback][formation][global_event]
///    Version:       1.0 - [Current Date]
///    Dependencies:  global.formation_notification_text (string)
///                   global.formation_notification_alpha (real, 0 to 1)
///                   global.formation_notification_timer (real, counts game steps)

function scr_trigger_formation_notification(_notification_string) {
    // =========================================================================
    // 1. SET NOTIFICATION GLOBALS
    // =========================================================================
    #region 1.1 Set Notification Globals
    global.formation_notification_text = _notification_string;
    global.formation_notification_alpha = 1.0; // Start fully visible
    global.formation_notification_timer = 0;   // Reset timer for the new notification
    // Educational: The actual fade-out and timing logic for this notification is handled in the controller's Step event.
    // This script only sets up the notification; the Step event will decrease alpha and hide the message after a set time.
    #endregion

    // =========================================================================
    // 2. DEBUG LOG (Optional)
    // =========================================================================
    #region 2.1 Debug Log
    // show_debug_message($"Formation Notification Triggered: '{_notification_string}'");
    #endregion
}