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

  // Autenticação de usuário existente (Aceita E-mail ou Nome de Usuário)
  Future<String?> signIn({
    required String email, // Aqui o parâmetro recebe o que foi digitado no campo (pode ser email ou nome)
    required String password,
  }) async {
    try {
      String emailToUse = email.trim();

      // Se o texto digitado não contiver '@', assumimos que é um Nome de Usuário
      if (!emailToUse.contains('@')) {
        final querySnapshot = await _firestore
            .collection('users')
            .where('name', isEqualTo: emailToUse)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          return 'Nome de usuário não encontrado.';
        }

        // Recupera o e-mail real associado àquele nome de usuário no documento do Firestore
        emailToUse = querySnapshot.docs.first.data()['email'] ?? '';
        
        if (emailToUse.isEmpty) {
          return 'E-mail não vinculado a este usuário.';
        }
      }

      // Faz o login utilizando o e-mail (seja o que o usuário digitou direto ou o encontrado pelo nome)
      await _auth.signInWithEmailAndPassword(
        email: emailToUse,
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