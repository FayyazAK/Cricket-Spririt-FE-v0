import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/themes/themes.dart';
import '../../models/player_model.dart';
import '../../services/api/api_service.dart';

class InvitePlayersView extends StatefulWidget {
  const InvitePlayersView({
    super.key,
    required this.clubId,
    required this.clubName,
    required this.currentPlayerCount,
    required this.maxPlayers,
    required this.existingPlayerIds,
    this.pendingPlayerIds = const {},
    this.rejectedPlayerIds = const {},
  });

  final String clubId;
  final String clubName;
  final int currentPlayerCount;
  final int maxPlayers;
  final Set<String> existingPlayerIds;
  final Set<String> pendingPlayerIds;
  final Set<String> rejectedPlayerIds;

  @override
  State<InvitePlayersView> createState() => _InvitePlayersViewState();
}

class _InvitePlayersViewState extends State<InvitePlayersView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  final List<Player> _players = [];
  final Set<String> _selectedPlayerIds = {};
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isInviting = false;
  String? _error;

  String _search = '';
  int _page = 1;
  final int _limit = 30;
  int _totalPages = 1;

  int get _availableSlots => widget.maxPlayers - widget.currentPlayerCount;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetch(reset: true);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoading || _isLoadingMore) return;
    if (_page >= _totalPages) return;

    final threshold = 300.0;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - threshold) {
      _fetch(reset: false);
    }
  }

  Future<void> _fetch({required bool reset}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _page = 1;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
        _error = null;
      });
    }

    try {
      final response = await apiService.getAllPlayers(
        search: _search.trim().isEmpty ? null : _search.trim(),
        page: _page,
        limit: _limit,
      );

      final data = (response['data'] as List?) ?? const [];
      final meta = (response['meta'] as Map<String, dynamic>?) ?? const {};

      final fetched = data
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList();

      final totalPages = (meta['totalPages'] as num?)?.toInt() ?? 1;

      if (!mounted) return;
      setState(() {
        if (reset) _players.clear();
        _players.addAll(fetched);
        _totalPages = totalPages;
        _page = _page + 1;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final next = value.trim();

    if (next.isEmpty) {
      if (next == _search) return;
      setState(() => _search = next);
      _fetch(reset: true);
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (next == _search) return;
      setState(() => _search = next);
      _fetch(reset: true);
    });
  }

  void _toggleSelection(String playerId) {
    setState(() {
      if (_selectedPlayerIds.contains(playerId)) {
        _selectedPlayerIds.remove(playerId);
      } else {
        if (_selectedPlayerIds.length < _availableSlots) {
          _selectedPlayerIds.add(playerId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You can only invite $_availableSlots more player${_availableSlots == 1 ? '' : 's'}',
              ),
              backgroundColor: CricketSpiritColors.error,
            ),
          );
        }
      }
    });
  }

  Future<void> _inviteSelectedPlayers() async {
    if (_selectedPlayerIds.isEmpty) return;

    setState(() => _isInviting = true);

    int successCount = 0;
    final errors = <String>[];

    for (final playerId in _selectedPlayerIds) {
      try {
        await apiService.invitePlayerToClub(
          clubId: widget.clubId,
          playerId: playerId,
        );
        successCount++;
      } catch (e) {
        final player = _players.firstWhere(
          (p) => p.id == playerId,
          orElse: () => _players.first,
        );
        errors.add('${player.firstName}: ${e.toString().replaceAll('Exception: ', '')}');
      }
    }

    if (!mounted) return;
    setState(() => _isInviting = false);

    if (successCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invitation${successCount > 1 ? 's' : ''} sent to $successCount player${successCount > 1 ? 's' : ''}',
          ),
          backgroundColor: CricketSpiritColors.primary,
        ),
      );
    }

    if (errors.isNotEmpty && mounted) {
      _showErrorsDialog(errors);
    }

    if (successCount > 0 && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _showErrorsDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CricketSpiritColors.card,
        title: const Text('Some invitations failed'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: errors
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '• $e',
                        style: TextStyle(
                          color: CricketSpiritColors.mutedForeground,
                          fontSize: 14,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _normalizeImageUrl(String? url) {
    if (url == null) return null;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final host = ApiService.baseUrl.split('/api/v1').first;
    if (trimmed.startsWith('/')) return '$host$trimmed';
    return '$host/$trimmed';
  }

  bool _isPlayerAlreadyInClub(String? playerId) {
    if (playerId == null) return false;
    return widget.existingPlayerIds.contains(playerId);
  }

  bool _isPlayerPending(String? playerId) {
    if (playerId == null) return false;
    return widget.pendingPlayerIds.contains(playerId);
  }

  bool _isPlayerRejected(String? playerId) {
    if (playerId == null) return false;
    return widget.rejectedPlayerIds.contains(playerId);
  }

  String? _getDisabledReason(String? playerId) {
    if (_isPlayerAlreadyInClub(playerId)) return 'Already in club';
    if (_isPlayerPending(playerId)) return 'Invitation pending';
    if (_isPlayerRejected(playerId)) return 'Previously rejected';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: CricketSpiritColors.background,
      appBar: AppBar(
        title: const Text('Invite Players'),
        backgroundColor: CricketSpiritColors.background,
      ),
      body: Column(
        children: [
          // Header info
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.clubName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.people_outline,
                      label: 'Current',
                      value: '${widget.currentPlayerCount}/${widget.maxPlayers}',
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: Icons.person_add_outlined,
                      label: 'Available',
                      value: '$_availableSlots',
                      highlight: true,
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: Icons.check_circle_outline,
                      label: 'Selected',
                      value: '${_selectedPlayerIds.length}',
                      highlight: _selectedPlayerIds.isNotEmpty,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search players...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: CricketSpiritColors.card,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, _) {
                    if (value.text.trim().isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      icon: const Icon(Icons.close),
                    );
                  },
                ),
              ),
            ),
          ),

          const Divider(height: 1),

          // Players list
          Expanded(
            child: _isLoading && _players.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: CricketSpiritColors.primary,
                    ),
                  )
                : _error != null && _players.isEmpty
                    ? _ErrorState(
                        message: _error!,
                        onRetry: () => _fetch(reset: true),
                      )
                    : _players.isEmpty
                        ? _EmptyState(hasSearch: _search.isNotEmpty)
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount:
                                _players.length + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= _players.length) {
                                return const _LoadingIndicator();
                              }
                              final player = _players[index];
                              final disabledReason = _getDisabledReason(player.id);
                              final isDisabled = disabledReason != null;
                              final isSelected = player.id != null &&
                                  _selectedPlayerIds.contains(player.id);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _SelectablePlayerCard(
                                  player: player,
                                  photoUrl:
                                      _normalizeImageUrl(player.profilePicture),
                                  isSelected: isSelected,
                                  isDisabled: isDisabled,
                                  disabledReason: disabledReason,
                                  onTap: isDisabled || player.id == null
                                      ? null
                                      : () => _toggleSelection(player.id!),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedPlayerIds.isNotEmpty
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CricketSpiritColors.card,
                  border: Border(
                    top: BorderSide(
                      color: CricketSpiritColors.border.withOpacity(0.5),
                    ),
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _isInviting ? null : _inviteSelectedPlayers,
                  child: _isInviting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: CricketSpiritColors.primaryForeground,
                          ),
                        )
                      : Text(
                          'Send ${_selectedPlayerIds.length} Invitation${_selectedPlayerIds.length > 1 ? 's' : ''}',
                        ),
                ),
              ),
            )
          : null,
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlight
            ? CricketSpiritColors.primary.withOpacity(0.15)
            : CricketSpiritColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight
              ? CricketSpiritColors.primary.withOpacity(0.3)
              : CricketSpiritColors.border.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: highlight
                ? CricketSpiritColors.primary
                : CricketSpiritColors.mutedForeground,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: CricketSpiritColors.mutedForeground,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: highlight
                      ? CricketSpiritColors.primary
                      : CricketSpiritColors.foreground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectablePlayerCard extends StatelessWidget {
  const _SelectablePlayerCard({
    required this.player,
    required this.photoUrl,
    required this.isSelected,
    required this.isDisabled,
    this.disabledReason,
    this.onTap,
  });

  final Player player;
  final String? photoUrl;
  final bool isSelected;
  final bool isDisabled;
  final String? disabledReason;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = '${player.firstName} ${player.lastName}'.trim();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? CricketSpiritColors.primary.withOpacity(0.1)
              : CricketSpiritColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? CricketSpiritColors.primary
                : CricketSpiritColors.border.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Selection indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? CricketSpiritColors.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? CricketSpiritColors.primary
                          : CricketSpiritColors.border,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: CricketSpiritColors.primaryForeground,
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Profile picture
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CricketSpiritColors.secondary,
                    border: Border.all(
                      color: CricketSpiritColors.border.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: photoUrl != null
                        ? Image.network(
                            photoUrl!,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            errorBuilder: (_, __, ___) => _photoPlaceholder(),
                          )
                        : _photoPlaceholder(),
                  ),
                ),
                const SizedBox(width: 12),

                // Player info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name.isEmpty ? 'Player' : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: CricketSpiritColors.mutedForeground,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              player.address.city,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: CricketSpiritColors.mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (disabledReason != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: CricketSpiritColors.secondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            disabledReason!,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: CricketSpiritColors.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Player type badge
                _badge(context, _prettyType(player.playerType)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CricketSpiritColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: CricketSpiritColors.primary,
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
          size: 24,
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
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: CricketSpiritColors.primary,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: CricketSpiritColors.error,
            ),
            const SizedBox(height: 12),
            Text('Failed to load players', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: CricketSpiritColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasSearch});

  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_outline,
              size: 72,
              color: CricketSpiritColors.mutedForeground,
            ),
            const SizedBox(height: 12),
            Text(
              hasSearch ? 'No matching players' : 'No players found',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Try a different search term'
                  : 'No players registered yet',
              style: textTheme.bodyMedium?.copyWith(
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
