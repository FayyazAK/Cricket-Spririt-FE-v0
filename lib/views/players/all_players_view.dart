import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/themes/themes.dart';
import '../../models/player_model.dart';
import '../../services/api/api_service.dart';
import 'player_view_page.dart';

class AllPlayersView extends StatefulWidget {
  const AllPlayersView({super.key});

  @override
  State<AllPlayersView> createState() => _AllPlayersViewState();
}

class _AllPlayersViewState extends State<AllPlayersView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  Timer? _filtersDebounce;

  final List<Player> _players = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  bool _isLoadingCities = true;
  List<String> _cities = const [];

  // Query state
  static const String _defaultSortBy = 'createdAt';
  static const String _defaultSortOrder = 'desc';

  String _search = '';
  String? _city;
  String? _playerType; // BATSMAN | BOWLER | ALL_ROUNDER
  int _page = 1;
  final int _limit = 30;
  int _totalPages = 1;
  int _total = 0;
  String _sortBy = _defaultSortBy;
  String _sortOrder = _defaultSortOrder;

  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCities();
    _fetch(reset: true);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _filtersDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    setState(() => _isLoadingCities = true);
    try {
      final raw = await rootBundle.loadString('assets/cities_by_province.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      final all = <String>{};
      for (final entry in decoded.entries) {
        final list = (entry.value as List)
            .map((e) => (e as Map<String, dynamic>)['name'] as String)
            .where((name) => name.trim().isNotEmpty);
        all.addAll(list);
      }

      final cities = all.toList()..sort();
      if (!mounted) return;
      setState(() {
        _cities = cities;
        _isLoadingCities = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cities = const [];
        _isLoadingCities = false;
      });
    }
  }

  void _onScroll() {
    if (_isLoading || _isLoadingMore) return;
    if (_page >= _totalPages) return;

    // Trigger a bit before reaching bottom
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
        city: (_city == null || _city!.trim().isEmpty) ? null : _city!.trim(),
        playerType: _playerType,
        search: _search.trim().isEmpty ? null : _search.trim(),
        page: _page,
        limit: _limit,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      final data = (response['data'] as List?) ?? const [];
      final meta = (response['meta'] as Map<String, dynamic>?) ?? const {};

      final fetched = data
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList();

      final totalPages = (meta['totalPages'] as num?)?.toInt() ?? 1;
      final total = (meta['total'] as num?)?.toInt() ?? fetched.length;

      if (!mounted) return;
      setState(() {
        if (reset) _players.clear();
        _players.addAll(fetched);

        _totalPages = totalPages;
        _total = total;
        _page = _page + 1; // next page to load

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

  Future<void> _refresh() async {
    await _fetch(reset: true);
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final next = value.trim();
    // Clear should feel instant (don't wait for debounce).
    if (next.isEmpty) {
      if (next == _search) return;
      setState(() => _search = next);
      _fetch(reset: true);
      return;
    }

    _searchDebounce = Timer(const Duration(seconds: 1), () {
      if (next == _search) return;
      setState(() => _search = next);
      _fetch(reset: true);
    });
  }

  void _applyFilters({String? city, String? playerType}) {
    setState(() {
      _city = city;
      _playerType = playerType;
    });
    _fetch(reset: true);
  }

  void _applyFiltersDebounced({String? city, String? playerType}) {
    _filtersDebounce?.cancel();
    final nextCity = city;
    final nextType = playerType;
    _filtersDebounce = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      _applyFilters(city: nextCity, playerType: nextType);
    });
  }

  void _applySorting({required String sortBy, required String sortOrder}) {
    setState(() {
      _sortBy = sortBy;
      _sortOrder = sortOrder;
    });
    _fetch(reset: true);
  }

  InputDecoration _compactDecoration({
    required String hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: CricketSpiritColors.card,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _resetAll() {
    _searchController.clear();
    _searchDebounce?.cancel();
    _filtersDebounce?.cancel();
    setState(() {
      _search = '';
      _city = null;
      _playerType = null;
      _sortBy = _defaultSortBy;
      _sortOrder = _defaultSortOrder;
    });
    _fetch(reset: true);
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasActiveFilters =
        (_city?.trim().isNotEmpty ?? false) || _playerType != null;
    final hasNonDefaultSort =
        _sortBy != _defaultSortBy || _sortOrder != _defaultSortOrder;
    final hasActiveQuery = _search.trim().isNotEmpty || hasActiveFilters || hasNonDefaultSort;

    return Scaffold(
      backgroundColor: CricketSpiritColors.background,
      appBar: AppBar(
        title: const Text('All Players'),
        backgroundColor: CricketSpiritColors.background,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Search + Filters toggle
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        decoration: _compactDecoration(
                          hintText: 'Search players...',
                          prefixIcon: Icons.search,
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
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => setState(() => _showFilters = !_showFilters),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: CricketSpiritColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: CricketSpiritColors.border.withOpacity(0.6),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.tune),
                            if (hasActiveFilters || hasNonDefaultSort)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: CricketSpiritColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _isLoading ? 'Loading...' : '${_players.length} of $_total',
                      style: textTheme.bodySmall?.copyWith(
                        color: CricketSpiritColors.mutedForeground,
                      ),
                    ),
                    const Spacer(),
                    if (hasActiveQuery)
                      TextButton(
                        onPressed: _resetAll,
                        child: const Text('Reset'),
                      ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: _showFilters
                      ? Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: CricketSpiritColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: CricketSpiritColors.border.withOpacity(0.6),
                            ),
                          ),
                          child: Column(
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isNarrow = constraints.maxWidth < 420;

                                  final cityField = DropdownButtonFormField<String?>(
                                    value: _city,
                                    isExpanded: true,
                                    items: <DropdownMenuItem<String?>>[
                                      const DropdownMenuItem<String?>(
                                        value: null,
                                        child: Text('Any city'),
                                      ),
                                      ..._cities.map(
                                        (c) => DropdownMenuItem<String?>(
                                          value: c,
                                          child: Text(
                                            c,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                    ],
                                    onChanged: _isLoadingCities
                                        ? null
                                        : (v) => _applyFiltersDebounced(
                                              city: v,
                                              playerType: _playerType,
                                            ),
                                    decoration: _compactDecoration(
                                      hintText: _isLoadingCities ? 'Loading cities...' : 'City',
                                      prefixIcon: Icons.location_city_outlined,
                                      suffixIcon: (_city == null)
                                          ? null
                                          : IconButton(
                                              onPressed: () {
                                                _filtersDebounce?.cancel();
                                                _applyFilters(city: null, playerType: _playerType);
                                              },
                                              icon: const Icon(Icons.close),
                                            ),
                                    ),
                                  );

                                  final typeField = DropdownButtonFormField<String?>(
                                    value: _playerType,
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem<String?>(
                                        value: null,
                                        child: Text('Any type'),
                                      ),
                                      DropdownMenuItem<String?>(
                                        value: 'BATSMAN',
                                        child: Text('Batsman'),
                                      ),
                                      DropdownMenuItem<String?>(
                                        value: 'BOWLER',
                                        child: Text('Bowler'),
                                      ),
                                      DropdownMenuItem<String?>(
                                        value: 'ALL_ROUNDER',
                                        child: Text('All‑rounder'),
                                      ),
                                    ],
                                    onChanged: (v) =>
                                        _applyFilters(city: _city, playerType: v),
                                    decoration: _compactDecoration(
                                      hintText: 'Player type',
                                      prefixIcon: Icons.sports_cricket_outlined,
                                    ),
                                  );

                                  if (isNarrow) {
                                    return Column(
                                      children: [
                                        cityField,
                                        const SizedBox(height: 10),
                                        typeField,
                                      ],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      Expanded(child: cityField),
                                      const SizedBox(width: 10),
                                      SizedBox(width: 180, child: typeField),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final isNarrow = constraints.maxWidth < 420;

                                  final sortByField =
                                      DropdownButtonFormField<String>(
                                    value: _sortBy,
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'createdAt',
                                        child: Text('Created'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'updatedAt',
                                        child: Text('Updated'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'firstName',
                                        child: Text('First name'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'lastName',
                                        child: Text('Last name'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'city',
                                        child: Text('City'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'playerType',
                                        child: Text('Player type'),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      if (v == null) return;
                                      _applySorting(
                                        sortBy: v,
                                        sortOrder: _sortOrder,
                                      );
                                    },
                                    decoration: _compactDecoration(
                                      hintText: 'Sort by',
                                      prefixIcon: Icons.sort,
                                    ),
                                  );

                                  final orderButton = OutlinedButton.icon(
                                    onPressed: () {
                                      final next =
                                          _sortOrder == 'asc' ? 'desc' : 'asc';
                                      _applySorting(sortBy: _sortBy, sortOrder: next);
                                    },
                                    icon: Icon(
                                      _sortOrder == 'asc'
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      size: 18,
                                    ),
                                    label: Text(_sortOrder.toUpperCase()),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );

                                  if (isNarrow) {
                                    return Column(
                                      children: [
                                        sortByField,
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          child: orderButton,
                                        ),
                                      ],
                                    );
                                  }

                                  return Row(
                                    children: [
                                      Expanded(child: sortByField),
                                      const SizedBox(width: 10),
                                      orderButton,
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
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
                          ? _EmptyState(
                              hasQuery: hasActiveQuery,
                              onReset: () {
                                _resetAll();
                              },
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _players.length + (_isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= _players.length) {
                                  return const _LoadingCard();
                                }
                                final p = _players[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _PlayerCard(
                                    player: p,
                                    photoUrl: _normalizeImageUrl(p.profilePicture),
                                    onTap: () {
                                      if (p.id != null && p.id!.isNotEmpty) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => PlayerViewPage(playerId: p.id!),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.player,
    required this.photoUrl,
    this.onTap,
  });

  final Player player;
  final String? photoUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = '${player.firstName} ${player.lastName}'.trim();
    final bowling = player.bowlingTypes;

    return GestureDetector(
      onTap: onTap,
      child: Card(
      elevation: 1,
      shadowColor: Colors.black12,
      color: CricketSpiritColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: CricketSpiritColors.border.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Profile picture circle
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CricketSpiritColors.secondary,
                border: Border.all(
                  color: CricketSpiritColors.border.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: photoUrl != null
                    ? Image.network(
                        photoUrl!,
                        fit: BoxFit.cover,
                        width: 70,
                        height: 70,
                        errorBuilder: (context, error, stackTrace) =>
                            _photoPlaceholder(),
                      )
                    : _photoPlaceholder(),
              ),
            ),
            const SizedBox(width: 14),
            // Details on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  Text(
                    name.isEmpty ? 'Player' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      color: CricketSpiritColors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // City
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
                  const SizedBox(height: 8),
                  // Badges row: type, WK, hands
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _badge(context, _prettyType(player.playerType)),
                      if (player.isWicketKeeper) _badge(context, 'WK'),
                      _badge(context, player.batHand == 'LEFT' ? 'LHB' : 'RHB'),
                      if (player.bowlHand != null && player.bowlHand!.isNotEmpty)
                        _badge(context, player.bowlHand == 'LEFT' ? 'LA' : 'RA'),
                    ],
                  ),
                  // Bowling types as badges
                  if (bowling.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: bowling
                          .map((b) => _badge(context, b.fullName))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _badge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: CricketSpiritColors.primary.withValues(alpha: 0.15),
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
          size: 32,
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

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: CricketSpiritColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Loading more players...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CricketSpiritColors.mutedForeground,
              ),
            ),
          ],
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
  const _EmptyState({
    required this.hasQuery,
    required this.onReset,
  });

  final bool hasQuery;
  final VoidCallback onReset;

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
              hasQuery ? 'No matching players' : 'No players found',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              hasQuery
                  ? 'Try changing search, filters, or sorting.'
                  : 'Please pull to refresh.',
              style: textTheme.bodyMedium?.copyWith(
                color: CricketSpiritColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasQuery) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.clear_all),
                label: const Text('Reset'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
