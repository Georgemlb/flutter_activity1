import 'package:flutter/material.dart';
import '../models/player.dart';

String _label(int step) {
  const bands = ['Beginners', 'Intermediate', 'G', 'F', 'E', 'D', 'Open'];
  const ticks = ['Weak', 'Mid', 'Strong'];
  final b = bands[step ~/ 3];
  final t = ticks[step % 3];
  return '$t $b';
}

class PlayerTile extends StatelessWidget {
  final Player p;
  final VoidCallback? onTap;
  const PlayerTile({super.key, required this.p, this.onTap});

  @override
  Widget build(BuildContext context) {
    // If levelStart == levelEnd, show only one label
    final levelText = p.levelStart == p.levelEnd
        ? _label(p.levelStart)
        : '${_label(p.levelStart)} → ${_label(p.levelEnd)}';

    return Card(
      child: ListTile(
        title: Text(p.nickname),
        subtitle: Text(p.fullName),
        trailing: Text(
          levelText,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        onTap: onTap,
      ),
    );
  }
}
