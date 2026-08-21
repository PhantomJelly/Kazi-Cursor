import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kazi/authentication/models/auth_user.dart';
import 'package:kazi/authentication/services/auth_config.dart';

class GoogleNotConfiguredException implements Exception {
  @override
  String toString() => 'Google sign-in is not configured yet.';
}

class GoogleAuthService {
  GoogleSignIn? get _googleSignIn {
    if (!AuthConfig.isGoogleConfigured) return null;

    return GoogleSignIn(
      clientId: kIsWeb ? AuthConfig.googleWebClientId : null,
      serverClientId: AuthConfig.googleWebClientId,
      scopes: ['email', 'profile'],
    );
  }

  Future<AuthUser?> signIn() async {
    if (!AuthConfig.isGoogleConfigured || _googleSignIn == null) {
      throw GoogleNotConfiguredException();
    }

    final account = await _googleSignIn!.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    return AuthUser(
      id: account.id,
      email: account.email,
      displayName: account.displayName,
      photoUrl: account.photoUrl,
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn?.signOut().timeout(const Duration(seconds: 2));
    } catch (_) {}
  }
}
