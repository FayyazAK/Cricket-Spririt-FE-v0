import 'package:flutter/material.dart';
import '../../app/themes/themes.dart';

class AllClubsView extends StatelessWidget {
  const AllClubsView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Clubs'),
        backgroundColor: CricketSpiritColors.background,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_outlined,
                size: 80,
                color: CricketSpiritColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'All Clubs',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Clubs list will be displayed here',
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
