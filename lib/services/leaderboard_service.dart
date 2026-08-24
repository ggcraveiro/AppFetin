import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Busca o top 10 para a tela de ranking
  Future<List<Map<String, dynamic>>> getTopUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .orderBy('treesPlanted', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Descobre a posição (ranking) exata do usuário logado atual
  Future<int> getCurrentUserRank() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 0;

      // Pega os dados do usuário atual para saber quantas árvores ele tem
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return 0;

      int userTrees = (userDoc.data() as Map<String, dynamic>)['treesPlanted'] ?? 0;

      // Conta quantos usuários têm mais árvores que ele
      QuerySnapshot higherRanked = await _firestore
          .collection('users')
          .where('treesPlanted', isGreaterThan: userTrees)
          .get();

      // A posição dele é a quantidade de pessoas acima + 1
      return higherRanked.docs.length + 1;
    } catch (e) {
      return 0;
    }
  }
}