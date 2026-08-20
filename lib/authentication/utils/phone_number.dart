/// Namibia-first phone helpers for profile contact numbers.
String toE164Phone(String input) {
  final trimmed = input.trim();
  var digits = trimmed.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  if (digits.startsWith('264')) return '+$digits';
  if (digits.startsWith('0')) return '+264${digits.substring(1)}';
  if (trimmed.startsWith('+')) return '+$digits';
  return '+264$digits';
}
