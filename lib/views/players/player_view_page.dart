import 'dart:ui';
import 'package:flutter/material.dart';

import '../../app/themes/themes.dart';
import '../../models/player_model.dart';
import '../../services/api/api_service.dart';

class PlayerViewPage extends StatefulWidget {
  const PlayerViewPage({
    super.key,
    required this.playerId,
  });

  final String playerId;

  @override
  State<PlayerViewPage> createState() => _PlayerViewPageState();
}

class _PlayerViewPageState extends State<PlayerViewPage> {
  bool _isLoading = true;
  String? _error;
  Player? _player;

  @override
  void initState() {
    super.initState();
    _fetchPlayerDetails();
  }

  Future<void> _fetchPlayerDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await apiService.getPlayerById(widget.playerId);
      if (response['data'] != null) {
        _player = Player.fromJson(response['data'] as Map<String, dynamic>);
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  String? _getFullImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final host = ApiService.baseUrl.split('/api/v1').first;
    return '$host/$trimmed';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: CricketSpiritColors.background,
      appBar: AppBar(
        title: const Text('Player Profile'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CricketSpiritColors.primary,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchPlayerDetails,
            ),
        ],
      ),
      body: _buildBody(textTheme),
    );
  }

  Widget _buildBody(TextTheme textTheme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: CricketSpiritColors.primary,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: CricketSpiritColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load player',
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: textTheme.bodyMedium?.copyWith(
                  color: CricketSpiritColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchPlayerDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_player == null) {
      return const Center(
        child: Text('Player not found'),
      );
    }

    return _buildPlayerView(textTheme);
  }

  Widget _buildPlayerView(TextTheme textTheme) {
    final player = _player!;
    final photoUrl = _getFullImageUrl(player.profilePicture);
    final dob = '${player.dateOfBirth.day}/${player.dateOfBirth.month}/${player.dateOfBirth.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Player Header
          _buildGlassmorphicCard(
            child: Column(
              children: [
                // Photo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CricketSpiritColors.primary,
                  ),
                  child: ClipOval(
                    child: photoUrl != null
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            headers: apiService.accessToken != null
                                ? {'Authorization': 'Bearer ${apiService.accessToken}'}
                                : null,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                '${player.firstName[0]}${player.lastName[0]}'.toUpperCase(),
                                style: textTheme.displayLarge?.copyWith(
                                  color: CricketSpiritColors.primaryForeground,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              '${player.firstName[0]}${player.lastName[0]}'.toUpperCase(),
                              style: textTheme.displayLarge?.copyWith(
                                color: CricketSpiritColors.primaryForeground,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  '${player.firstName} ${player.lastName}',
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Player Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: CricketSpiritColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatPlayerType(player.playerType),
                    style: textTheme.labelLarge?.copyWith(
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Personal Info
          _buildGlassmorphicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Info',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _infoRow('Gender', player.gender),
                _infoRow('Date of Birth', dob),
                _infoRow('Location', '${player.address.city}, ${player.address.state}'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Playing Info
          _buildGlassmorphicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Playing Details',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _infoRow('Player Type', _formatPlayerType(player.playerType)),
                _infoRow('Wicket Keeper', player.isWicketKeeper ? 'Yes' : 'No'),
                _infoRow('Batting Hand', _formatHand(player.batHand)),
                if (player.playerType != 'BATSMAN') ...[
                  _infoRow('Bowling Hand', _formatHand(player.bowlHand ?? '')),
                ],
              ],
            ),
          ),

          // Bowling Types
          if (player.playerType != 'BATSMAN' && player.bowlingTypes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildGlassmorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bowling Types',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: player.bowlingTypes
                        .map(
                          (t) => Chip(
                            label: Text('${t.fullName} (${t.shortName})'),
                            backgroundColor: CricketSpiritColors.primary.withOpacity(0.15),
                            side: BorderSide(
                              color: CricketSpiritColors.primary.withOpacity(0.25),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],

          // Address
          const SizedBox(height: 16),
          _buildGlassmorphicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Address',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  [
                    if ((player.address.street ?? '').trim().isNotEmpty)
                      player.address.street!.trim(),
                    if ((player.address.townSuburb ?? '').trim().isNotEmpty)
                      player.address.townSuburb!.trim(),
                    player.address.city,
                    player.address.state,
                    player.address.country,
                    if ((player.address.postalCode ?? '').trim().isNotEmpty)
                      player.address.postalCode!.trim(),
                  ].join(', '),
                  style: textTheme.bodyMedium?.copyWith(
                    color: CricketSpiritColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: CricketSpiritColors.card.withOpacity(0.7),
            borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
            border: Border.all(
              color: CricketSpiritColors.border.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: CricketSpiritColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  String _formatPlayerType(String type) {
    switch (type.toUpperCase()) {
      case 'BATSMAN':
        return 'Batsman';
      case 'BOWLER':
        return 'Bowler';
      case 'ALL_ROUNDER':
        return 'All-Rounder';
      default:
        return type;
    }
  }

  String _formatHand(String hand) {
    switch (hand.toUpperCase()) {
      case 'LEFT':
        return 'Left Hand';
      case 'RIGHT':
        return 'Right Hand';
      default:
        return hand;
    }
  }
}
