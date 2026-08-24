import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/leaderboard_service.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaderboardService = LeaderboardService();

    return Scaffold(
      backgroundColor: const Color(0xFF081c15),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF52b788)),
        title: Text(
          'Ranking 🌿',
          style: GoogleFonts.playfairDisplay(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: leaderboardService.getTopUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF52b788)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum dado de ranking encontrado.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final users = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final name = user['name'] ?? 'Anônimo';
              final trees = user['treesPlanted'] ?? 0;
              
              Color rankColor = const Color(0xFF1b4332);
              if (index == 0) rankColor = const Color(0xFFd4af37); // Ouro
              else if (index == 1) rankColor = const Color(0xFFc0c0c0); // Prata
              else if (index == 2) rankColor = const Color(0xFFcd7f32); // Bronze

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1b4332),
                  borderRadius: BorderRadius.circular(16),
                  border: index < 3 ? Border.all(color: rankColor, width: 2) : null,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rankColor,
                    child: Text(
                      '${index + 1}º',
                      style: TextStyle(
                        color: index < 3 ? const Color(0xFF081c15) : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.eco, color: Color(0xFF52b788), size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '$trees árvores',
                        style: const TextStyle(
                          color: Color(0xFF52b788),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}