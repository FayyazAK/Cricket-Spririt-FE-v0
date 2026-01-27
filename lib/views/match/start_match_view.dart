import 'package:flutter/material.dart';
import '../../app/themes/themes.dart';

class StartMatchView extends StatefulWidget {
  const StartMatchView({super.key});

  @override
  State<StartMatchView> createState() => _StartMatchViewState();
}

class _StartMatchViewState extends State<StartMatchView> {
  static const _stepLabels = ['Setup', 'Toss', 'Players'];
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

  static const _oversOptions = [5, 10, 20, 50];
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

  bool get _canProceedSetup =>
      _homeTeam != null &&
      _awayTeam != null &&
      _homeTeam != _awayTeam;

  bool get _canProceedToss =>
      _tossWinner != null && _electedTo != null;

  bool get _canProceedPlayers {
    if (_striker == null || _nonStriker == null || _bowler == null) return false;
    final s = {_striker!, _nonStriker!, _bowler!};
    return s.length == 3;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: CricketSpiritColors.background,
      appBar: AppBar(
        backgroundColor: CricketSpiritColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Match',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: CricketSpiritColors.foreground,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step progress
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: List.generate(_stepLabels.length * 2 - 1, (i) {
                if (i.isOdd) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        height: 2,
                        color: _currentStep > i ~/ 2
                            ? CricketSpiritColors.primary
                            : CricketSpiritColors.border,
                      ),
                    ),
                  );
                }
                final step = i ~/ 2;
                final active = _currentStep == step;
                final completed = _currentStep > step;
                return Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: completed
                              ? CricketSpiritColors.primary
                              : active
                                  ? CricketSpiritColors.primary
                                  : CricketSpiritColors.border,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: completed
                              ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: CricketSpiritColors.primaryForeground,
                                )
                              : Text(
                                  '${step + 1}',
                                  style: textTheme.labelLarge?.copyWith(
                                    fontSize: 12,
                                    color: active || completed
                                        ? CricketSpiritColors.primaryForeground
                                        : CricketSpiritColors.mutedForeground,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _stepLabels[step],
                        style: textTheme.bodySmall?.copyWith(
                          color: active || completed
                              ? CricketSpiritColors.foreground
                              : CricketSpiritColors.mutedForeground,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _buildStepContent(),
            ),
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
    final sameTeamError = _homeTeam != null &&
        _awayTeam != null &&
        _homeTeam == _awayTeam;

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
          _buildSectionHeader(
            icon: Icons.groups,
            label: 'Teams',
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),
          Text(
            'Home Team',
            style: textTheme.bodyMedium?.copyWith(
              color: CricketSpiritColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _homeTeam,
            hint: 'Select home team',
            items: _teams,
            onChanged: (value) => setState(() => _homeTeam = value),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          Text(
            'Away Team',
            style: textTheme.bodyMedium?.copyWith(
              color: CricketSpiritColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _awayTeam,
            hint: 'Select away team',
            items: _teams,
            onChanged: (value) => setState(() => _awayTeam = value),
          ),
          if (sameTeamError) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: CricketSpiritColors.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Home and away team must be different',
                  style: textTheme.bodySmall?.copyWith(
                    color: CricketSpiritColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          _buildSectionHeader(
            icon: Icons.tune,
            label: 'Match format',
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),
          Text(
            'Overs',
            style: textTheme.bodyMedium?.copyWith(
              color: CricketSpiritColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _oversOptions.map<Widget>((o) {
              final selected = _overs == o;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _overs = o),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? CricketSpiritColors.primary
                          : CricketSpiritColors.white10,
                      borderRadius: BorderRadius.circular(
                        CricketSpiritRadius.button,
                      ),
                      border: Border.all(
                        color: selected
                            ? CricketSpiritColors.primary
                            : CricketSpiritColors.border,
                      ),
                    ),
                    child: Text(
                      '$o',
                      style: textTheme.titleMedium?.copyWith(
                        color: selected
                            ? CricketSpiritColors.primaryForeground
                            : CricketSpiritColors.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Ball Type',
            style: textTheme.bodyMedium?.copyWith(
              color: CricketSpiritColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _ballType,
            hint: 'Leather',
            items: const ['Leather', 'Tennis', 'Rubber'],
            onChanged: (value) => setState(() => _ballType = value!),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canProceedSetup
                  ? () => setState(() => _currentStep = 1)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Next: Toss'),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String label,
    required TextTheme textTheme,
  }) {
    return Row(
      children: [
        Icon(icon, color: CricketSpiritColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: textTheme.titleMedium?.copyWith(
            color: CricketSpiritColors.foreground,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD97706),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.monetization_on,
              size: 32,
              color: Color(0xFFD97706),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Who won the toss?',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: CricketSpiritColors.foreground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Select the team and what they chose',
            style: textTheme.bodySmall?.copyWith(
              color: CricketSpiritColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTossTeamButton(
                  team: homeTeam,
                  subtitle: 'Home',
                  isSelected: _tossWinner == homeTeam,
                  onTap: () => setState(() => _tossWinner = homeTeam),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTossTeamButton(
                  team: awayTeam,
                  subtitle: 'Away',
                  isSelected: _tossWinner == awayTeam,
                  onTap: () => setState(() => _tossWinner = awayTeam),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Elected to',
            style: textTheme.bodyMedium?.copyWith(
              color: CricketSpiritColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildElectionButton(
                  label: 'Bat',
                  isSelected: _electedTo == 'Bat',
                  onTap: () => setState(() => _electedTo = 'Bat'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildElectionButton(
                  label: 'Bowl',
                  isSelected: _electedTo == 'Bowl',
                  onTap: () => setState(() => _electedTo = 'Bowl'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep = 0),
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
                  onPressed: _canProceedToss
                      ? () => setState(() => _currentStep = 2)
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Next: Players'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
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
    final hasDuplicatePlayers = _striker != null &&
        _nonStriker != null &&
        _bowler != null &&
        !_canProceedPlayers;

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
          Text(
            'Select opening batsmen and bowler',
            style: textTheme.bodySmall?.copyWith(
              color: CricketSpiritColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(
            icon: Icons.people,
            label: 'Opening batsmen',
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),
          Text(
            'Striker',
            style: textTheme.bodyMedium?.copyWith(
              color: CricketSpiritColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _striker,
            hint: 'Select striker',
            items: _players,
            onChanged: (value) => setState(() => _striker = value),
          ),
          const SizedBox(height: 16),
          Text(
            'Non-striker',
            style: textTheme.bodyMedium?.copyWith(
              color: CricketSpiritColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _nonStriker,
            hint: 'Select non-striker',
            items: _players,
            onChanged: (value) => setState(() => _nonStriker = value),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(
            icon: Icons.sports_cricket,
            label: 'Opening bowler',
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),
          Text(
            'Bowler',
            style: textTheme.bodyMedium?.copyWith(
              color: CricketSpiritColors.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _bowler,
            hint: 'Select bowler',
            items: _players,
            onChanged: (value) => setState(() => _bowler = value),
          ),
          if (hasDuplicatePlayers) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: CricketSpiritColors.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Striker, non-striker, and bowler must be different',
                    style: textTheme.bodySmall?.copyWith(
                      color: CricketSpiritColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep = 1),
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
                  onPressed: _canProceedPlayers ? _onStartMatch : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, size: 20),
                      SizedBox(width: 8),
                      Text('Start Match'),
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

  void _onStartMatch() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Match started successfully!'),
        backgroundColor: CricketSpiritColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    // TODO: Navigate to live scoring screen
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

