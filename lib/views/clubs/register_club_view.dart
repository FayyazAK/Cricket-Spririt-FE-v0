import 'package:flutter/material.dart';
import '../../app/themes/themes.dart';

class RegisterClubView extends StatelessWidget {
  const RegisterClubView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register a Club'),
        backgroundColor: CricketSpiritColors.background,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_business_outlined,
                size: 80,
                color: CricketSpiritColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Register a Club',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Club registration page will be implemented here',
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
