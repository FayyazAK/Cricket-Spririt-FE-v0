import 'package:flutter/material.dart';
import '../../app/themes/themes.dart';
import '../profile/profile_view.dart';

class StartMatchView extends StatefulWidget {
  const StartMatchView({super.key});

  @override
  State<StartMatchView> createState() => _StartMatchViewState();
}

class _StartMatchViewState extends State<StartMatchView> {
  int _currentStep = 0;

  // Step 1: Match Setup
  String? _homeTeam;
  String? _awayTeam;
  int _overs = 20;
  String _ballType = 'Leather';

  // Step 2: Toss
  String? _tossWinner;
  String? _electedTo;

  // Step 3: Players
  String? _striker;
  String? _nonStriker;
  String? _bowler;

  final List<String> _teams = [
    'Royal Strikers',
    'City Titans',
    'Green Valley',
    'Metro Knights',
    'Thunder Kings',
    'Desert Eagles',
  ];

  final List<String> _players = [
    'Bilal Ahmed',
    'Ali Khan',
    'Steve Smith',
    'David Warner',
    'Virat Kohli',
    'Babar Azam',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: CricketSpiritColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  'CS',
                  style: textTheme.titleMedium?.copyWith(
                    color: CricketSpiritColors.primaryForeground,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
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
                fontSize: 18,
              ),
            ),
            Text(
              'SPIRIT',
              style: textTheme.headlineSmall?.copyWith(
                color: CricketSpiritColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'START NEW MATCH',
                  style: textTheme.displaySmall?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure match settings, teams, and toss details.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: CricketSpiritColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          // Progress Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: CricketSpiritColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _currentStep >= 1
                          ? CricketSpiritColors.primary
                          : CricketSpiritColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _currentStep >= 2
                          ? CricketSpiritColors.primary
                          : CricketSpiritColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pop(); // Go back to home
          } else if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileView()),
            );
          }
        },
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

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildMatchSetupStep();
      case 1:
        return _buildTossStep();
      case 2:
        return _buildPlayersStep();
      default:
        return _buildMatchSetupStep();
    }
  }

  // Step 1: Match Setup
  Widget _buildMatchSetupStep() {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: CricketSpiritColors.card,
        borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
        border: Border.all(color: CricketSpiritColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Home Team
          Text(
            'Home Team',
            style: textTheme.titleMedium?.copyWith(
              color: CricketSpiritColors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            value: _homeTeam,
            hint: 'Royal Strikers',
            items: _teams,
            onChanged: (value) {
              setState(() {
                _homeTeam = value;
              });
            },
          ),
          const SizedBox(height: 24),
          // VS Badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: CricketSpiritColors.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'VS',
                style: textTheme.titleMedium?.copyWith(
                  color: CricketSpiritColors.mutedForeground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Away Team
          Text(
            'Away Team',
            style: textTheme.titleMedium?.copyWith(
              color: CricketSpiritColors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            value: _awayTeam,
            hint: 'City Titans',
            items: _teams,
            onChanged: (value) {
              setState(() {
                _awayTeam = value;
              });
            },
          ),
          const SizedBox(height: 24),
          // Overs and Ball Type
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overs',
                      style: textTheme.titleMedium?.copyWith(
                        color: CricketSpiritColors.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: CricketSpiritColors.white10,
                        borderRadius: BorderRadius.circular(
                          CricketSpiritRadius.input,
                        ),
                        border: Border.all(color: CricketSpiritColors.border),
                      ),
                      child: Text(
                        _overs.toString(),
                        style: textTheme.bodyMedium?.copyWith(
                          color: CricketSpiritColors.foreground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ball Type',
                      style: textTheme.titleMedium?.copyWith(
                        color: CricketSpiritColors.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      value: _ballType,
                      hint: 'Leather',
                      items: const ['Leather', 'Tennis', 'Rubber'],
                      onChanged: (value) {
                        setState(() {
                          _ballType = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Next Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 1;
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Next: Toss'),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step 2: Toss
  Widget _buildTossStep() {
    final textTheme = Theme.of(context).textTheme;
    final homeTeam = _homeTeam ?? 'Royal Strikers';
    final awayTeam = _awayTeam ?? 'City Titans';

    return Container(
      decoration: BoxDecoration(
        color: CricketSpiritColors.card,
        borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
        border: Border.all(color: CricketSpiritColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Toss Icon
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFD97706),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            'WHO WON THE TOSS?',
            style: textTheme.displaySmall?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Team Selection
          Row(
            children: [
              Expanded(
                child: _buildTossTeamButton(
                  team: homeTeam,
                  subtitle: 'Home',
                  isSelected: _tossWinner == homeTeam,
                  onTap: () {
                    setState(() {
                      _tossWinner = homeTeam;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTossTeamButton(
                  team: awayTeam,
                  subtitle: 'Away',
                  isSelected: _tossWinner == awayTeam,
                  onTap: () {
                    setState(() {
                      _tossWinner = awayTeam;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Elected to?
          Text(
            'Elected to?',
            style: textTheme.titleMedium?.copyWith(
              color: CricketSpiritColors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Bat/Bowl Selection
          Row(
            children: [
              Expanded(
                child: _buildElectionButton(
                  label: 'Bat',
                  isSelected: _electedTo == 'Bat',
                  onTap: () {
                    setState(() {
                      _electedTo = 'Bat';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildElectionButton(
                  label: 'Bowl',
                  isSelected: _electedTo == 'Bowl',
                  onTap: () {
                    setState(() {
                      _electedTo = 'Bowl';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = 0;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _tossWinner != null && _electedTo != null
                      ? () {
                          setState(() {
                            _currentStep = 2;
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Next: Players'),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Step 3: Players
  Widget _buildPlayersStep() {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: CricketSpiritColors.card,
        borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
        border: Border.all(color: CricketSpiritColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Opening Batsmen Section
          Row(
            children: [
              Icon(
                Icons.people,
                color: CricketSpiritColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'OPENING BATSMEN',
                style: textTheme.titleMedium?.copyWith(
                  color: CricketSpiritColors.foreground,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Striker
          Text(
            'STRIKER',
            style: textTheme.bodySmall?.copyWith(
              color: CricketSpiritColors.mutedForeground,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _striker,
            hint: 'Bilal Ahmed',
            items: _players,
            onChanged: (value) {
              setState(() {
                _striker = value;
              });
            },
          ),
          const SizedBox(height: 16),
          // Non-Striker
          Text(
            'NON-STRIKER',
            style: textTheme.bodySmall?.copyWith(
              color: CricketSpiritColors.mutedForeground,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _nonStriker,
            hint: 'Ali Khan',
            items: _players,
            onChanged: (value) {
              setState(() {
                _nonStriker = value;
              });
            },
          ),
          const SizedBox(height: 32),
          // Opening Bowler Section
          Row(
            children: [
              Icon(
                Icons.sports_cricket,
                color: Colors.red.shade400,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'OPENING BOWLER',
                style: textTheme.titleMedium?.copyWith(
                  color: CricketSpiritColors.foreground,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bowler
          Text(
            'BOWLER',
            style: textTheme.bodySmall?.copyWith(
              color: CricketSpiritColors.mutedForeground,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _bowler,
            hint: 'Steve Smith',
            items: _players,
            onChanged: (value) {
              setState(() {
                _bowler = value;
              });
            },
          ),
          const SizedBox(height: 32),
          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep = 1;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _striker != null &&
                          _nonStriker != null &&
                          _bowler != null
                      ? () {
                          // Navigate to live scoring screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Match started successfully!'),
                              backgroundColor: CricketSpiritColors.primary,
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Start Match'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: CricketSpiritColors.white10,
        borderRadius: BorderRadius.circular(CricketSpiritRadius.input),
        border: Border.all(color: CricketSpiritColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: textTheme.bodyMedium?.copyWith(
              color: CricketSpiritColors.mutedForeground,
            ),
          ),
          isExpanded: true,
          dropdownColor: CricketSpiritColors.card,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: CricketSpiritColors.mutedForeground,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: textTheme.bodyMedium?.copyWith(
                  color: CricketSpiritColors.foreground,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTossTeamButton({
    required String team,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? CricketSpiritColors.primary.withOpacity(0.1)
              : CricketSpiritColors.white10,
          borderRadius: BorderRadius.circular(CricketSpiritRadius.button),
          border: Border.all(
            color: isSelected
                ? CricketSpiritColors.primary
                : CricketSpiritColors.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              team,
              style: textTheme.titleMedium?.copyWith(
                color: isSelected
                    ? CricketSpiritColors.primary
                    : CricketSpiritColors.foreground,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: CricketSpiritColors.mutedForeground,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElectionButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? CricketSpiritColors.primary
              : CricketSpiritColors.white10,
          borderRadius: BorderRadius.circular(CricketSpiritRadius.button),
          border: Border.all(
            color: isSelected
                ? CricketSpiritColors.primary
                : CricketSpiritColors.border,
          ),
        ),
        child: Text(
          label,
          style: textTheme.titleMedium?.copyWith(
            color: isSelected
                ? CricketSpiritColors.primaryForeground
                : CricketSpiritColors.foreground,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

