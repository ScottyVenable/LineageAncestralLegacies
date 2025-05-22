/// obj_controller - Begin Step Event
///
/// Purpose:
///    Handles tasks that need to occur at the very beginning of each game step,
///    before most other Step events.
///
/// Metadata:
///    Summary:         Resets frame-specific global flags.
///    Usage:           obj_controller Begin Step Event.
///    Version:        1.0 - [Current Date]
///    Dependencies:  global.mouse_event_consumed_by_ui

// Reset frame-specific global flags
global.mouse_event_consumed_by_ui = false;