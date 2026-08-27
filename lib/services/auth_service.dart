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
      // 1. Cria a credencial
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user == null) return 'Erro ao criar credencial de usuário.';

      // 2. Atualiza o perfil no Auth
      await user.updateDisplayName(name.trim());

      // 3. Aguarda explicitamente a gravação no Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'treesPlanted': 0,
        'streak': 0,
        'maxStreak': 0,
        'score': 0,
      }, SetOptions(merge: true)); // Garantia de merge caso o documento exista

      return null; // Sucesso garantido
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } on FirebaseException catch (e) {
      // Pega erros específicos do Firestore (ex: offline, permissão)
      print('Erro no Firestore: ${e.code} - ${e.message}');
      return 'Erro ao salvar perfil no banco de dados: ${e.message}';
    } catch (e) {
      print('Erro geral: $e');
      return 'Ocorreu um erro inesperado ao criar a conta.';
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
    case 'invalid-credential':
    case 'invalid-login-credentials':
      return 'E-mail ou senha incorretos. Verifique suas credenciais.';
    case 'user-not-found':
      return 'Nenhum usuário encontrado para este e-mail.';
    case 'wrong-password':
      return 'Senha incorreta. Tente novamente.';
    case 'email-already-in-use':
      return 'Este e-mail já está em uso por outra conta.';
    case 'invalid-email':
      return 'O e-mail digitado é inválido.';
    case 'weak-password':
      return 'A senha deve ter pelo menos 6 caracteres.';
    case 'user-disabled':
      return 'Esta conta de usuário foi desativada.';
    case 'too-many-requests':
      return 'Muitas tentativas malsucedidas. Tente novamente mais tarde.';
    case 'network-request-failed':
      return 'Falha na conexão de rede. Verifique sua internet.';
    default:
      print('Código de erro do Firebase Auth não mapeado: ${e.code}');
      return 'E-mail ou senha incorretos. Tente novamente.';
  }
}
}