import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Login com Google via Firebase.
  /// Retorna o Firebase ID Token para enviar ao backend.
  Future<GoogleSignInResult> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Login com Google cancelado pelo usuário');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final idToken = await userCredential.user?.getIdToken();

    if (idToken == null) {
      throw Exception('Não foi possível obter o token do Google');
    }

    return GoogleSignInResult(
      idToken: idToken,
      email: userCredential.user?.email ?? '',
      name: userCredential.user?.displayName ?? '',
      photoUrl: userCredential.user?.photoURL,
    );
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}

class GoogleSignInResult {
  final String idToken;
  final String email;
  final String name;
  final String? photoUrl;

  GoogleSignInResult({
    required this.idToken,
    required this.email,
    required this.name,
    this.photoUrl,
  });
}
