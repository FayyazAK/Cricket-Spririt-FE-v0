import 'package:flutter/material.dart';
import '../../app/themes/themes.dart';

class MatchesView extends StatelessWidget {
  const MatchesView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        backgroundColor: CricketSpiritColors.background,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_cricket_outlined,
                size: 80,
                color: CricketSpiritColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Matches',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Matches page will be implemented here',
                style: textTheme.bodyLarge?.copyWith(
                  color: CricketSpiritColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
