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
    // 1. Cria a conta no Firebase Authentication
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // 2. Garante que o usuário foi criado e possui um UID
    if (userCredential.user != null) {
      String uid = userCredential.user!.uid;

      // 3. Salva os dados na coleção 'users' com o ID correspondente ao UID do Auth
      await _firestore.collection('users').doc(uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'treesCount': 0,
      });
      
      print("✅ Usuário salvo com sucesso no Firestore!");
      return null; // Sucesso
    }
    return "Erro ao obter o usuário cadastrado.";
  } on FirebaseAuthException catch (e) {
    print("❌ Erro no Auth: ${e.code}");
    return _handleAuthException(e);
  } catch (e) {
    print("❌ Erro ao salvar dados no Firestore: $e");
    return "Conta criada no Auth, mas falhou ao salvar dados do perfil. Tente novamente.";
  }
}

  // Autenticação de usuário existente (Aceita E-mail ou Nome de Usuário)
Future<String?> signIn({
  required String identifier, // Pode ser e-mail ou nome de usuário
  required String password,
}) async {
  try {
    String emailToUse = identifier.trim();

    // 1. Se NÃO contiver '@', assume que é um nome de usuário
    if (!emailToUse.contains('@')) {
      // Busca no Firestore na coleção 'users' onde o campo 'name' ou 'username' seja igual ao digitado
      final querySnapshot = await _firestore
          .collection('users')
          .where('name', isEqualTo: emailToUse)
          .limit(1)
          .get();

      // Se não encontrar nenhum documento com esse nome
      if (querySnapshot.docs.isEmpty) {
        return 'Nome de usuário não encontrado.';
      }

      // Extrai o e-mail cadastrado nesse documento
      final userData = querySnapshot.docs.first.data();
      emailToUse = userData['email'] ?? '';

      if (emailToUse.isEmpty) {
        return 'Nenhum e-mail associado a este nome de usuário.';
      }
    }

    // 2. Realiza o login no Firebase Auth utilizando o e-mail resolvido
    await _auth.signInWithEmailAndPassword(
      email: emailToUse,
      password: password.trim(),
    );

    return null; // Sucesso
  } on FirebaseAuthException catch (e) {
    print("Erro do FirebaseAuth: ${e.code}");
    return _handleAuthException(e);
  } catch (e) {
    print("Erro no login: $e");
    return 'E-mail, usuário ou senha incorretos.';
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