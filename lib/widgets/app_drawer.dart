import 'package:flutter/material.dart';
import '../app/app_state.dart';
import '../app/themes/themes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isPlayerRole = (appState.currentUser?.role ?? '').toUpperCase() == 'PLAYER';

    return Drawer(
      backgroundColor: CricketSpiritColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: CricketSpiritColors.background,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: CricketSpiritColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'CS',
                        style: textTheme.titleMedium?.copyWith(
                          color: CricketSpiritColors.primaryForeground,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CRICKET ',
                    style: textTheme.headlineSmall?.copyWith(
                      color: CricketSpiritColors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'SPIRIT',
                    style: textTheme.headlineSmall?.copyWith(
                      color: CricketSpiritColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Players Section
          _buildSectionHeader(context, 'PLAYERS'),
          if (!isPlayerRole)
            _buildDrawerItem(
              context,
              icon: Icons.person_add_outlined,
              title: 'Register as Player',
              route: '/register-player',
            ),
          _buildDrawerItem(
            context,
            icon: Icons.people_outlined,
            title: 'All Players',
            route: '/all-players',
          ),
          const Divider(),

          // Clubs Section
          _buildSectionHeader(context, 'CLUBS'),
          _buildDrawerItem(
            context,
            icon: Icons.add_business_outlined,
            title: 'Register a Club',
            route: '/register-club',
          ),
          _buildDrawerItem(
            context,
            icon: Icons.business_outlined,
            title: 'All Clubs',
            route: '/all-clubs',
          ),
          const Divider(),

          // Tournaments Section
          _buildSectionHeader(context, 'TOURNAMENTS'),
          _buildDrawerItem(
            context,
            icon: Icons.emoji_events_outlined,
            title: 'Tournaments',
            route: '/tournaments',
          ),
          const Divider(),

          // Matches Section
          _buildSectionHeader(context, 'MATCHES'),
          _buildDrawerItem(
            context,
            icon: Icons.sports_cricket_outlined,
            title: 'Matches',
            route: '/matches',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: textTheme.labelSmall?.copyWith(
          color: CricketSpiritColors.mutedForeground,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: CricketSpiritColors.foreground,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        Navigator.pushNamed(context, route);
      },
    );
  }
}
