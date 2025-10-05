import 'package:flutter/material.dart';
import '../models/player.dart';
import '../widgets/player_tile.dart';
import 'player_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Player> _players = [];
  String _query = '';

  List<Player> get _filtered {
    if (_query.isEmpty) return _players;
    final q = _query.toLowerCase();
    return _players.where((p) =>
      p.nickname.toLowerCase().contains(q) ||
      p.fullName.toLowerCase().contains(q)
    ).toList();
  }

  void _addPlayer() async {
    final newPlayer = await Navigator.push<Player>(
      context,
      MaterialPageRoute(builder: (_) => const PlayerFormScreen()),
    );
    if (newPlayer != null) setState(() => _players.add(newPlayer));
  }

  void _editPlayer(Player p) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlayerFormScreen(existing: p)),
    );

    if (result is Player) {
      setState(() {
        final i = _players.indexWhere((x) => x.id == result.id);
        if (i != -1) _players[i] = result;
      });
    } else if (result is Map && result['deleted'] == true) {
      setState(() => _players.removeWhere((x) => x.id == result['id']));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player deleted')),
        );
        }
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Players')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or nickname',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final p = _filtered[i];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Dismissible(
                    key: ValueKey(p.id),
                    direction: DismissDirection.endToStart, // swipe left to delete
                    // small swipe (20%) is enough to reveal/trigger delete
                    dismissThresholds: const { DismissDirection.endToStart: 0.1 },

                    // red circular trash icon revealed on swipe
                    background: Container(
                      color: Colors.transparent, // keep card look unchanged
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFE53935),
                        child: Icon(Icons.delete_outline, color: Colors.white, size: 22),
                      ),
                    ),

                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete player?'),
                          content: Text('Remove ${p.nickname}?'),
                          actions: [
                            TextButton(
                              onPressed: ()=>Navigator.pop(context,false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: ()=>Navigator.pop(context,true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ?? false;
                    },
                    onDismissed: (_) =>
                        setState(() => _players.removeWhere((x) => x.id == p.id)),

                    // keep your original card; PlayerTile already returns a Card
                    child: PlayerTile(p: p, onTap: () => _editPlayer(p)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPlayer,
        icon: const Icon(Icons.add),
        label: const Text('Add New Player'),
      ),
    );
  }
}
