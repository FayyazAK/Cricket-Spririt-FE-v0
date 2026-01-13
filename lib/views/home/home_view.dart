import 'package:flutter/material.dart';

import '../../app/themes/themes.dart';
import '../../widgets/app_drawer.dart';
import '../profile/profile_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;

  void _onBottomNavTap(int index) {
    if (index == 3) {
      // Navigate to Profile
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProfileView()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: CricketSpiritColors.background,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: CricketSpiritColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'CS',
                      style: textTheme.titleMedium?.copyWith(
                        color: CricketSpiritColors.primaryForeground,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
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

          // Hero Section
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CricketSpiritColors.background,
                    CricketSpiritColors.background.withOpacity(0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Background pattern/image placeholder
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=800',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: CricketSpiritColors.card.withOpacity(0.3),
                          );
                        },
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 48,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: CricketSpiritColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: CricketSpiritColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'THE SPIRIT OF THE GAME',
                            style: textTheme.labelLarge?.copyWith(
                              fontSize: 11,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Main Heading
                        Text(
                          'PLAY. SCORE.',
                          style: textTheme.displayLarge?.copyWith(
                            fontSize: 48,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'DOMINATE.',
                          style: textTheme.displayLarge?.copyWith(
                            fontSize: 48,
                            height: 1.1,
                            color: CricketSpiritColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Subtitle
                        Text(
                          'The ultimate platform for grassroots cricket.\nManage your club, score matches live, and\ntrack your stats like a pro.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: CricketSpiritColors.mutedForeground,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Action Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/start-match');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('Start a Match'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Live Action Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LIVE ACTION',
                            style: textTheme.displaySmall?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Happening right now across the league',
                            style: textTheme.bodySmall?.copyWith(
                              color: CricketSpiritColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('View All'),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Live Match Cards
                  _buildLiveMatchCard(
                    league: 'PREMIER LEAGUE T20 • FINAL',
                    team1: 'ROYAL STRIKERS',
                    team1Status: 'Batting',
                    team1Score: '184/4',
                    team1Overs: '15.2 OV',
                    team2: 'CITY TITANS',
                    team2Score: '182/7',
                    team2Overs: '20.0 OV',
                    status: 'ROYAL STRIKERS NEED 12 RUNS IN 10 BALLS',
                    isLive: true,
                  ),
                  const SizedBox(height: 12),
                  _buildLiveMatchCard(
                    league: 'CLUB CHAMPIONSHIP • SEMI FINAL',
                    team1: 'GREEN VALLEY',
                    team1Status: 'Batting',
                    team1Score: '95/3',
                    team1Overs: '12.4 OV',
                    team2: 'METRO KNIGHTS',
                    team2Score: '167/8',
                    team2Overs: '20.0 OV',
                    status: 'GREEN VALLEY NEED 73 RUNS',
                    isLive: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        backgroundColor: CricketSpiritColors.card,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: CricketSpiritColors.primary,
        unselectedItemColor: CricketSpiritColors.mutedForeground,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_cricket_outlined),
            activeIcon: Icon(Icons.sports_cricket),
            label: 'MATCHES',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'TOURNAMENTS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'PROFILE',
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMatchCard({
    required String league,
    required String team1,
    required String team1Status,
    required String team1Score,
    required String team1Overs,
    required String team2,
    required String team2Score,
    required String team2Overs,
    required String status,
    required bool isLive,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: CricketSpiritColors.card,
        borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
        border: Border.all(color: CricketSpiritColors.border),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  league,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: CricketSpiritColors.mutedForeground,
                  ),
                ),
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LIVE',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Teams
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Team 1
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: CricketSpiritColors.primary.withOpacity(0.2),
                          child: Text(
                            team1[0],
                            style: textTheme.titleMedium?.copyWith(
                              color: CricketSpiritColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team1,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              team1Status,
                              style: textTheme.bodySmall?.copyWith(
                                color: CricketSpiritColors.primary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          team1Score,
                          style: textTheme.displaySmall?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          team1Overs,
                          style: textTheme.bodySmall?.copyWith(
                            color: CricketSpiritColors.mutedForeground,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Team 2
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: CricketSpiritColors.secondary,
                          child: Text(
                            team2[0],
                            style: textTheme.titleMedium?.copyWith(
                              color: CricketSpiritColors.mutedForeground,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          team2,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: CricketSpiritColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          team2Score,
                          style: textTheme.displaySmall?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: CricketSpiritColors.mutedForeground,
                          ),
                        ),
                        Text(
                          team2Overs,
                          style: textTheme.bodySmall?.copyWith(
                            color: CricketSpiritColors.mutedForeground,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: CricketSpiritColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(CricketSpiritRadius.card),
                bottomRight: Radius.circular(CricketSpiritRadius.card),
              ),
            ),
            child: Text(
              status,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: CricketSpiritColors.primary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

