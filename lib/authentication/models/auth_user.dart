/// Signed-in user returned from Google or demo mock auth.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isMock = false,
    this.idToken,
    this.accessToken,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isMock;
  final String? idToken;
  final String? accessToken;
}
