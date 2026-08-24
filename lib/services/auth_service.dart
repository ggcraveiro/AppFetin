import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obter o usuário logado atualmente
  User? get currentUser => _auth.currentUser;

  // Stream para escutar mudanças no estado da sessão em tempo real
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Cadastro de novo usuário
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Cria a credencial no Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // 2. Atualiza o nome de exibição no perfil
      await credential.user?.updateDisplayName(name.trim());

      // 3. Salva a ficha do usuário no Firestore
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'name': name.trim(),
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'treesPlanted': 0,
          'streak': 0,
        });
      }

      return null; // Retorno nulo indica sucesso
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  // Autenticação de usuário existente
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  // Sair da conta
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Mapeamento de mensagens de erro do Firebase
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'invalid-email':
        return 'O e-mail digitado não é válido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }
}