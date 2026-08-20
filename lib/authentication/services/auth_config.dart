/// Google OAuth configuration.
///
/// Replace [googleWebClientId] with your Web client ID from Google Cloud Console:
/// APIs & Services → Credentials → OAuth 2.0 Client IDs → Web client
class AuthConfig {
  AuthConfig._();

  static const String googleWebClientId =
      '887770333540-qdggn80dsoggu43a43lgjnr6um79vvhe.apps.googleusercontent.com';

  static const String _placeholderPrefix = 'YOUR_WEB_CLIENT_ID';

  static bool get isGoogleConfigured =>
      googleWebClientId.isNotEmpty &&
      !googleWebClientId.startsWith(_placeholderPrefix);
}
