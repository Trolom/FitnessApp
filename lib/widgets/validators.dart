class Validators {
static String? nonEmpty(String? v) {
if (v == null || v.trim().isEmpty) return 'This field is required';
return null;
}


static String? email(String? v) {
if (v == null || v.trim().isEmpty) return 'Email is required';
final r = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
if (!r.hasMatch(v.trim())) return 'Enter a valid email';
return null;
}


static String? password(String? v) {
if (v == null || v.isEmpty) return 'Password is required';
if (v.length < 6) return 'At least 6 characters';
return null;
}


static String? confirmPassword(String? v, String original) {
if (v == null || v.isEmpty) return 'Please confirm your password';
if (v != original) return 'Passwords do not match';
return null;
}
}