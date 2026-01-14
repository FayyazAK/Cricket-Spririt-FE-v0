import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/themes/themes.dart';
import '../../services/api/api_service.dart';

enum PlayerCategory { club, invited, rejected }

class ClubPlayersView extends StatefulWidget {
  const ClubPlayersView({
    super.key,
    required this.clubId,
    required this.clubName,
    required this.isOwner,
    required this.clubPlayers,
    required this.pendingPlayers,
    required this.rejectedPlayers,
    required this.totalCount,
    required this.maxPlayers,
  });

  final String clubId;
  final String clubName;
  final bool isOwner;
  final List<Map<String, dynamic>> clubPlayers;
  final List<Map<String, dynamic>> pendingPlayers;
  final List<Map<String, dynamic>> rejectedPlayers;
  final int totalCount;
  final int maxPlayers;

  @override
  State<ClubPlayersView> createState() => _ClubPlayersViewState();
}

class _ClubPlayersViewState extends State<ClubPlayersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Only show all tabs if owner, otherwise just show club players
    _tabController = TabController(
      length: widget.isOwner ? 3 : 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        title: const Text('Club Players'),
        backgroundColor: CricketSpiritColors.background,
        bottom: widget.isOwner
            ? TabBar(
                controller: _tabController,
                labelColor: CricketSpiritColors.primary,
                unselectedLabelColor: CricketSpiritColors.mutedForeground,
                indicatorColor: CricketSpiritColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  _buildTab('Players', widget.clubPlayers.length, CricketSpiritColors.primary),
                  _buildTab('Invited', widget.pendingPlayers.length, Colors.orange),
                  _buildTab('Rejected', widget.rejectedPlayers.length, CricketSpiritColors.error),
                ],
              )
            : null,
      ),
      body: Column(
        children: [
          // Header stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CricketSpiritColors.card.withOpacity(0.5),
              border: Border(
                bottom: BorderSide(
                  color: CricketSpiritColors.border.withOpacity(0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.clubName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Squad Roster',
                        style: textTheme.bodySmall?.copyWith(
                          color: CricketSpiritColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: CricketSpiritColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: CricketSpiritColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 18,
                        color: CricketSpiritColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.totalCount}/${widget.maxPlayers}',
                        style: textTheme.titleMedium?.copyWith(
                          color: CricketSpiritColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: widget.isOwner
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPlayerList(
                        widget.clubPlayers,
                        PlayerCategory.club,
                        emptyMessage: 'No players in the club yet',
                        emptyIcon: Icons.people_outline,
                      ),
                      _buildPlayerList(
                        widget.pendingPlayers,
                        PlayerCategory.invited,
                        emptyMessage: 'No pending invitations',
                        emptyIcon: Icons.mail_outline,
                      ),
                      _buildPlayerList(
                        widget.rejectedPlayers,
                        PlayerCategory.rejected,
                        emptyMessage: 'No rejected invitations',
                        emptyIcon: Icons.person_off_outlined,
                      ),
                    ],
                  )
                : _buildPlayerList(
                    widget.clubPlayers,
                    PlayerCategory.club,
                    emptyMessage: 'No players in the club yet',
                    emptyIcon: Icons.people_outline,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int count, Color color) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerList(
    List<Map<String, dynamic>> players,
    PlayerCategory category, {
    required String emptyMessage,
    required IconData emptyIcon,
  }) {
    if (players.isEmpty) {
      return _buildEmptyState(emptyMessage, emptyIcon);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _PlayerCard(
            player: player,
            category: category,
            photoUrl: _getFullImageUrl(player['profilePicture']),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: CricketSpiritColors.mutedForeground.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: textTheme.bodyLarge?.copyWith(
                color: CricketSpiritColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.player,
    required this.category,
    required this.photoUrl,
  });

  final Map<String, dynamic> player;
  final PlayerCategory category;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firstName = player['firstName'] ?? '';
    final lastName = player['lastName'] ?? '';
    final name = '$firstName $lastName'.trim();
    final playerType = player['playerType'] ?? '';

    // Get the appropriate date based on category
    late String dateLabel;
    late String dateValue;
    switch (category) {
      case PlayerCategory.club:
        dateLabel = 'Joined';
        dateValue = _formatDate(player['joinedAt']);
        break;
      case PlayerCategory.invited:
        dateLabel = 'Invited';
        dateValue = _formatDate(player['invitedAt']);
        break;
      case PlayerCategory.rejected:
        dateLabel = 'Rejected';
        dateValue = _formatDate(player['rejectedAt']);
        break;
    }

    // Category-specific colors
    Color accentColor;
    Color backgroundColor;
    switch (category) {
      case PlayerCategory.club:
        accentColor = CricketSpiritColors.primary;
        backgroundColor = CricketSpiritColors.card;
        break;
      case PlayerCategory.invited:
        accentColor = Colors.orange;
        backgroundColor = Colors.orange.withOpacity(0.05);
        break;
      case PlayerCategory.rejected:
        accentColor = CricketSpiritColors.error;
        backgroundColor = CricketSpiritColors.error.withOpacity(0.05);
        break;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withOpacity(0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Profile picture
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CricketSpiritColors.secondary,
                    border: Border.all(
                      color: accentColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: photoUrl != null
                        ? Image.network(
                            photoUrl!,
                            fit: BoxFit.cover,
                            width: 56,
                            height: 56,
                            headers: apiService.accessToken != null
                                ? {'Authorization': 'Bearer ${apiService.accessToken}'}
                                : null,
                            errorBuilder: (_, __, ___) => _photoPlaceholder(),
                          )
                        : _photoPlaceholder(),
                  ),
                ),
                const SizedBox(width: 14),

                // Player info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? 'Player' : name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _badge(context, _prettyType(playerType), accentColor),
                          const SizedBox(width: 8),
                          Text(
                            '$dateLabel: $dateValue',
                            style: textTheme.bodySmall?.copyWith(
                              color: CricketSpiritColors.mutedForeground,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      // Show expiry for pending invitations
                      if (category == PlayerCategory.invited &&
                          player['invitationExpiresAt'] != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 12,
                              color: Colors.orange.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Expires: ${_formatDate(player['invitationExpiresAt'])}',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.orange.withOpacity(0.7),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Status indicator
                _buildStatusIcon(category),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(PlayerCategory category) {
    IconData icon;
    Color color;

    switch (category) {
      case PlayerCategory.club:
        icon = Icons.check_circle;
        color = CricketSpiritColors.primary;
        break;
      case PlayerCategory.invited:
        icon = Icons.schedule;
        color = Colors.orange;
        break;
      case PlayerCategory.rejected:
        icon = Icons.cancel;
        color = CricketSpiritColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 20,
        color: color,
      ),
    );
  }

  Widget _badge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      color: CricketSpiritColors.secondary,
      child: const Center(
        child: Icon(
          Icons.person_outline,
          size: 28,
          color: CricketSpiritColors.mutedForeground,
        ),
      ),
    );
  }

  String _prettyType(String type) {
    switch (type) {
      case 'BATSMAN':
        return 'Batsman';
      case 'BOWLER':
        return 'Bowler';
      case 'ALL_ROUNDER':
        return 'All‑rounder';
      default:
        return type;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
