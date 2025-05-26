// Check if an initialization method exists for the profile and call it.
// Using method_get(instance, "method_name") which returns 'undefined' if the method doesn't exist.
// This is the correct way to check for a method's existence in GML.
var _init_method = method_get(self, "initialize_from_profile");
if (!is_undefined(_init_method)) {
    // Call the method if it exists
    _init_method(self);
}