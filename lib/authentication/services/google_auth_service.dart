import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kazi/authentication/models/auth_user.dart';
import 'package:kazi/authentication/services/auth_config.dart';

class GoogleAuthService {
  GoogleSignIn? get _googleSignIn {
    if (!AuthConfig.isGoogleConfigured) return null;

    return GoogleSignIn(
      clientId: kIsWeb ? AuthConfig.googleWebClientId : null,
      scopes: ['email', 'profile'],
    );
  }

  /// Signs in with Google when configured, otherwise returns a demo user.
  Future<AuthUser?> signIn() async {
    if (!AuthConfig.isGoogleConfigured) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      return AuthUser.mock();
    }

    final account = await _googleSignIn!.signIn();
    if (account == null) return null;

    return AuthUser(
      id: account.id,
      email: account.email,
      displayName: account.displayName,
      photoUrl: account.photoUrl,
    );
  }

  Future<void> signOut() async {
    if (_googleSignIn != null) {
      await _googleSignIn!.signOut();
    }
  }
}
