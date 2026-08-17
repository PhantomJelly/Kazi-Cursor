/// Signed-in user returned from Google or demo mock auth.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isMock = false,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isMock;

  factory AuthUser.mock() {
    return const AuthUser(
      id: 'mock-google-user',
      email: 'demo.user@gmail.com',
      displayName: 'Demo User',
      isMock: true,
    );
  }
}
