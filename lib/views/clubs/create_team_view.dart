import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/themes/themes.dart';
import '../../services/api/api_service.dart';

class CreateTeamView extends StatefulWidget {
  const CreateTeamView({
    super.key,
    required this.clubId,
    required this.clubName,
    required this.clubPlayers,
  });

  final String clubId;
  final String clubName;
  final List<Map<String, dynamic>> clubPlayers;

  @override
  State<CreateTeamView> createState() => _CreateTeamViewState();
}

class _CreateTeamViewState extends State<CreateTeamView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final Set<String> _selectedPlayerIds = {};
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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

  void _togglePlayerSelection(String playerId) {
    setState(() {
      if (_selectedPlayerIds.contains(playerId)) {
        _selectedPlayerIds.remove(playerId);
      } else {
        _selectedPlayerIds.add(playerId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      for (final player in widget.clubPlayers) {
        final id = player['id']?.toString();
        if (id != null) {
          _selectedPlayerIds.add(id);
        }
      }
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedPlayerIds.clear();
    });
  }

  Future<void> _createTeam() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedPlayerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one player for the team'),
          backgroundColor: CricketSpiritColors.error,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final response = await apiService.createTeam(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        clubId: widget.clubId,
        playerIds: _selectedPlayerIds.toList(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message'] ?? 'Team created successfully!',
          ),
          backgroundColor: CricketSpiritColors.primary,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: CricketSpiritColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: CricketSpiritColors.background,
      appBar: AppBar(
        title: const Text('Create Team'),
        backgroundColor: CricketSpiritColors.background,
      ),
      body: Column(
        children: [
          // Header with club name
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
                        'New Team',
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
                      const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: CricketSpiritColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_selectedPlayerIds.length} selected',
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

          // Form and player list
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Team Details Card
                    _buildGlassmorphicCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Team Details',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Team name *',
                              hintText: 'e.g., Lions A, Senior Team',
                              prefixIcon: Icon(Icons.groups_outlined),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Team name is required'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 2,
                            maxLength: 200,
                            decoration: const InputDecoration(
                              labelText: 'Description (optional)',
                              hintText: 'e.g., Senior team for competitive matches',
                              alignLabelWithHint: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Player Selection Card
                    _buildGlassmorphicCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Select Players *',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: _selectAll,
                                    child: const Text('Select All'),
                                  ),
                                  TextButton(
                                    onPressed: _deselectAll,
                                    child: const Text('Clear'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Choose players from your club roster to add to this team',
                            style: textTheme.bodySmall?.copyWith(
                              color: CricketSpiritColors.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (widget.clubPlayers.isEmpty)
                            _buildEmptyPlayersState(textTheme)
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.clubPlayers.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final player = widget.clubPlayers[index];
                                final playerId = player['id']?.toString();
                                final isSelected = playerId != null &&
                                    _selectedPlayerIds.contains(playerId);

                                return _SelectablePlayerCard(
                                  player: player,
                                  photoUrl: _getFullImageUrl(player['profilePicture']),
                                  isSelected: isSelected,
                                  onTap: playerId != null
                                      ? () => _togglePlayerSelection(playerId)
                                      : null,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
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
            onPressed: _isCreating ? null : _createTeam,
            child: _isCreating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CricketSpiritColors.primaryForeground,
                    ),
                  )
                : Text(
                    _selectedPlayerIds.isEmpty
                        ? 'Create Team'
                        : 'Create Team with ${_selectedPlayerIds.length} Player${_selectedPlayerIds.length > 1 ? 's' : ''}',
                  ),
          ),
        ),
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

  Widget _buildEmptyPlayersState(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: CricketSpiritColors.mutedForeground.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No players in club',
            style: textTheme.titleMedium?.copyWith(
              color: CricketSpiritColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add players to your club first before creating a team',
            style: textTheme.bodySmall?.copyWith(
              color: CricketSpiritColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
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
    this.onTap,
  });

  final Map<String, dynamic> player;
  final String? photoUrl;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firstName = player['firstName'] ?? '';
    final lastName = player['lastName'] ?? '';
    final name = '$firstName $lastName'.trim();
    final playerType = player['playerType'] ?? '';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? CricketSpiritColors.primary.withOpacity(0.1)
              : CricketSpiritColors.card.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? CricketSpiritColors.primary
                : CricketSpiritColors.border.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CricketSpiritColors.secondary,
                  border: Border.all(
                    color: isSelected
                        ? CricketSpiritColors.primary.withOpacity(0.5)
                        : CricketSpiritColors.border.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: photoUrl != null
                      ? Image.network(
                          photoUrl!,
                          fit: BoxFit.cover,
                          width: 46,
                          height: 46,
                          headers: apiService.accessToken != null
                              ? {'Authorization': 'Bearer ${apiService.accessToken}'}
                              : null,
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
                    const SizedBox(height: 2),
                    _badge(context, _prettyType(playerType)),
                  ],
                ),
              ),

              // Selection status icon
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: CricketSpiritColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: CricketSpiritColors.primary,
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
          size: 22,
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
