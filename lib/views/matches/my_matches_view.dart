import 'package:flutter/material.dart';

import '../../app/themes/themes.dart';
import '../../services/api/api_service.dart';
import '../../widgets/app_drawer.dart';

class MyMatchesView extends StatefulWidget {
  const MyMatchesView({super.key});

  @override
  State<MyMatchesView> createState() => _MyMatchesViewState();
}

class _MyMatchesViewState extends State<MyMatchesView> {
  final List<_CreatedMatch> _createdMatches = [];
  final List<_CompactMatch> _scorerMatches = [];
  final List<_CompactMatch> _teamMatches = [];
  final List<_CompactMatch> _ownerTeamMatches = [];
  final List<_ScorerInvitation> _scorerInvitations = [];
  final List<_TeamInvitation> _teamInvitations = [];
  final Set<String> _actingInvitations = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await apiService.getMyMatches();
      final data = response['data'] as Map<String, dynamic>? ?? {};
      final createdMatchesRaw = (data['createdMatches'] as List?) ?? const [];
      final scorerMatchesRaw = (data['scorerMatches'] as List?) ?? const [];
      final teamMatchesRaw = (data['teamMatches'] as List?) ?? const [];
      final ownerTeamMatchesRaw =
          (data['ownerTeamMatches'] as List?) ?? const [];
      final teamInvitationsRaw =
          (data['teamInvitations'] as List?) ?? const [];
      final invitationsRaw =
          (data['scorerInvitations'] as List?) ?? const [];

      _createdMatches
        ..clear()
        ..addAll(
          createdMatchesRaw
              .whereType<Map<String, dynamic>>()
              .map(_CreatedMatch.fromJson),
        );
      _scorerMatches
        ..clear()
        ..addAll(
          scorerMatchesRaw
              .whereType<Map<String, dynamic>>()
              .map(_CompactMatch.fromJson),
        );
      _teamMatches
        ..clear()
        ..addAll(
          teamMatchesRaw
              .whereType<Map<String, dynamic>>()
              .map(_CompactMatch.fromJson),
        );
      _ownerTeamMatches
        ..clear()
        ..addAll(
          ownerTeamMatchesRaw
              .whereType<Map<String, dynamic>>()
              .map(_CompactMatch.fromJson),
        );
      _scorerInvitations
        ..clear()
        ..addAll(
          invitationsRaw
              .whereType<Map<String, dynamic>>()
              .map(_ScorerInvitation.fromJson),
        );
      _teamInvitations
        ..clear()
        ..addAll(
          teamInvitationsRaw
              .whereType<Map<String, dynamic>>()
              .map(_TeamInvitation.fromJson),
        );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleInvitationAction({
    required String invitationId,
    required bool accept,
  }) async {
    setState(() => _actingInvitations.add(invitationId));
    try {
      if (accept) {
        await apiService.acceptScorerInvitation(invitationId);
      } else {
        await apiService.rejectScorerInvitation(invitationId);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accept
                ? 'Invitation accepted. You are the scorer.'
                : 'Invitation rejected.',
          ),
          backgroundColor: CricketSpiritColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: CricketSpiritColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _actingInvitations.remove(invitationId));
    }
  }

  Future<void> _handleTeamInvitationAction({
    required String invitationId,
    required bool accept,
  }) async {
    setState(() => _actingInvitations.add(invitationId));
    try {
      if (accept) {
        await apiService.acceptTeamInvitation(invitationId);
      } else {
        await apiService.rejectTeamInvitation(invitationId);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accept ? 'Team invitation accepted.' : 'Team invitation rejected.',
          ),
          backgroundColor: CricketSpiritColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: CricketSpiritColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _actingInvitations.remove(invitationId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final totalMatches =
        _createdMatches.length +
        _scorerMatches.length +
        _teamMatches.length +
        _ownerTeamMatches.length;
    final totalInvites =
        _scorerInvitations.length + _teamInvitations.length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: const Text('My Matches'),
          backgroundColor: CricketSpiritColors.background,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => Navigator.pushNamed(context, '/create-match'),
              tooltip: 'Create match',
            ),
          ],
          bottom: TabBar(
            labelColor: CricketSpiritColors.primary,
            unselectedLabelColor: CricketSpiritColors.mutedForeground,
            indicatorColor: CricketSpiritColors.primary,
            tabs: [
              Tab(text: 'Matches ($totalMatches)'),
              Tab(text: 'Invites ($totalInvites)'),
            ],
          ),
        ),
        body: _isLoading &&
                _createdMatches.isEmpty &&
                _scorerMatches.isEmpty &&
                _teamMatches.isEmpty &&
                _ownerTeamMatches.isEmpty &&
                _scorerInvitations.isEmpty &&
                _teamInvitations.isEmpty
            ? const Center(
                child: CircularProgressIndicator(
                  color: CricketSpiritColors.primary,
                ),
              )
            : Column(
                children: [
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CricketSpiritColors.error.withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(CricketSpiritRadius.card),
                        border: Border.all(color: CricketSpiritColors.error),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: textTheme.bodySmall?.copyWith(
                          color: CricketSpiritColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildMatchesTab(),
                        _buildInvitesTab(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMatchesTab() {
    if (_createdMatches.isEmpty &&
        _scorerMatches.isEmpty &&
        _teamMatches.isEmpty &&
        _ownerTeamMatches.isEmpty) {
      return _buildEmptyState(
        icon: Icons.sports_cricket_outlined,
        title: 'No matches yet',
        subtitle:
            'Your created, scorer, and team matches appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (_createdMatches.isNotEmpty) ...[
            _SectionHeader(
              title: 'Created matches',
              count: _createdMatches.length,
            ),
            const SizedBox(height: 12),
            ..._createdMatches.map((match) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CreatedMatchCard(match: match),
              );
            }),
            const SizedBox(height: 8),
          ],
          if (_scorerMatches.isNotEmpty) ...[
            _SectionHeader(
              title: 'Scorer matches',
              count: _scorerMatches.length,
            ),
            const SizedBox(height: 12),
            ..._scorerMatches.map((match) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CompactMatchCard(match: match),
              );
            }),
            const SizedBox(height: 8),
          ],
          if (_teamMatches.isNotEmpty) ...[
            _SectionHeader(
              title: 'Team matches',
              count: _teamMatches.length,
            ),
            const SizedBox(height: 12),
            ..._teamMatches.map((match) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CompactMatchCard(match: match),
              );
            }),
            const SizedBox(height: 8),
          ],
          if (_ownerTeamMatches.isNotEmpty) ...[
            _SectionHeader(
              title: 'Owner team matches',
              count: _ownerTeamMatches.length,
            ),
            const SizedBox(height: 12),
            ..._ownerTeamMatches.map((match) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CompactMatchCard(match: match),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildInvitesTab() {
    if (_scorerInvitations.isEmpty && _teamInvitations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.mail_outline,
        title: 'No invitations',
        subtitle: 'Scorer and team invites appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (_scorerInvitations.isNotEmpty) ...[
            _SectionHeader(
              title: 'Scorer invitations',
              count: _scorerInvitations.length,
            ),
            const SizedBox(height: 12),
            ..._scorerInvitations.map((invitation) {
              final isPending = invitation.status == 'PENDING';
              final isBusy = _actingInvitations.contains(invitation.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _InvitationCard(
                  invitation: invitation,
                  isPending: isPending,
                  isBusy: isBusy,
                  onAccept: isPending
                      ? () => _handleInvitationAction(
                            invitationId: invitation.id,
                            accept: true,
                          )
                      : null,
                  onReject: isPending
                      ? () => _handleInvitationAction(
                            invitationId: invitation.id,
                            accept: false,
                          )
                      : null,
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
          if (_teamInvitations.isNotEmpty) ...[
            _SectionHeader(
              title: 'Team invitations',
              count: _teamInvitations.length,
            ),
            const SizedBox(height: 12),
            ..._teamInvitations.map((invitation) {
              final isPending = invitation.status == 'PENDING';
              final isBusy = _actingInvitations.contains(invitation.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TeamInvitationCard(
                  invitation: invitation,
                  isPending: isPending,
                  isBusy: isBusy,
                  onAccept: isPending
                      ? () => _handleTeamInvitationAction(
                            invitationId: invitation.id,
                            accept: true,
                          )
                      : null,
                  onReject: isPending
                      ? () => _handleTeamInvitationAction(
                            invitationId: invitation.id,
                            accept: false,
                          )
                      : null,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 40),
        Icon(icon, size: 72, color: CricketSpiritColors.primary),
        const SizedBox(height: 16),
        Center(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CricketSpiritColors.mutedForeground,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        _StatusChip(
          label: '$count',
          tone: _StatusTone.neutral,
        ),
      ],
    );
  }
}

class _CreatedMatchCard extends StatelessWidget {
  const _CreatedMatchCard({required this.match});

  final _CreatedMatch match;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CricketSpiritColors.card,
        borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
        border: Border.all(color: CricketSpiritColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TeamVersusRow(team1: match.team1, team2: match.team2),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Scheduled',
            value: match.scheduledDateLabel,
          ),
          const SizedBox(height: 6),
          _InfoRow(label: 'Status', value: match.status),
          if (match.scorer != null) ...[
            const SizedBox(height: 6),
            _InfoRow(
              label: 'Scorer',
              value: match.scorer!.displayName,
            ),
          ],
          if (match.invitations.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Scorer invites',
              style: textTheme.bodySmall?.copyWith(
                color: CricketSpiritColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: match.invitations.map((invitation) {
                return _StatusChip(
                  label: invitation.label,
                  tone: _statusTone(invitation.status),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _CompactMatchCard extends StatelessWidget {
  const _CompactMatchCard({required this.match});

  final _CompactMatch match;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CricketSpiritColors.card,
        borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
        border: Border.all(color: CricketSpiritColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TeamVersusRow(team1: match.team1, team2: match.team2),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Scheduled',
            value: match.scheduledDateLabel,
          ),
          const SizedBox(height: 6),
          _InfoRow(label: 'Status', value: match.status),
          if (match.scorer != null) ...[
            const SizedBox(height: 6),
            _InfoRow(
              label: 'Scorer',
              value: match.scorer!.displayName,
            ),
          ],
        ],
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
    required this.isPending,
    required this.isBusy,
    required this.onAccept,
    required this.onReject,
  });

  final _ScorerInvitation invitation;
  final bool isPending;
  final bool isBusy;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CricketSpiritColors.card,
        borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
        border: Border.all(color: CricketSpiritColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TeamVersusRow(
            team1: invitation.match.team1,
            team2: invitation.match.team2,
          ),
          const SizedBox(height: 8),
          if (invitation.match.tournamentName != null) ...[
            _InfoRow(
              label: 'Tournament',
              value: invitation.match.tournamentName!,
            ),
            const SizedBox(height: 6),
          ],
          _InfoRow(
            label: 'Invited',
            value: invitation.invitedAtLabel,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Status',
                style: textTheme.bodySmall?.copyWith(
                  color: CricketSpiritColors.mutedForeground,
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(
                label: invitation.status,
                tone: _statusTone(invitation.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isBusy ? null : onReject,
                    child: isBusy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isBusy ? null : onAccept,
                    child: isBusy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: CricketSpiritColors.primaryForeground,
                            ),
                          )
                        : const Text('Accept'),
                  ),
                ),
              ],
            )
          else
            Text(
              invitation.status == 'ACCEPTED'
                  ? 'You are assigned as scorer for this match.'
                  : 'This invitation is no longer active.',
              style: textTheme.bodySmall?.copyWith(
                color: CricketSpiritColors.mutedForeground,
              ),
            ),
        ],
      ),
    );
  }
}

class _TeamInvitationCard extends StatelessWidget {
  const _TeamInvitationCard({
    required this.invitation,
    required this.isPending,
    required this.isBusy,
    required this.onAccept,
    required this.onReject,
  });

  final _TeamInvitation invitation;
  final bool isPending;
  final bool isBusy;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CricketSpiritColors.card,
        borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
        border: Border.all(color: CricketSpiritColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TeamVersusRow(
            team1: invitation.match.team1,
            team2: invitation.match.team2,
          ),
          const SizedBox(height: 8),
          _InfoRow(label: 'Invited team', value: invitation.team.name),
          if (invitation.match.tournamentName != null) ...[
            const SizedBox(height: 6),
            _InfoRow(
              label: 'Tournament',
              value: invitation.match.tournamentName!,
            ),
          ],
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Invited',
            value: invitation.invitedAtLabel,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Status',
                style: textTheme.bodySmall?.copyWith(
                  color: CricketSpiritColors.mutedForeground,
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(
                label: invitation.status,
                tone: _statusTone(invitation.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isBusy ? null : onReject,
                    child: isBusy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isBusy ? null : onAccept,
                    child: isBusy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: CricketSpiritColors.primaryForeground,
                            ),
                          )
                        : const Text('Accept'),
                  ),
                ),
              ],
            )
          else
            Text(
              invitation.status == 'ACCEPTED'
                  ? 'Team accepted for this match.'
                  : 'This invitation is no longer active.',
              style: textTheme.bodySmall?.copyWith(
                color: CricketSpiritColors.mutedForeground,
              ),
            ),
        ],
      ),
    );
  }
}

class _TeamVersusRow extends StatelessWidget {
  const _TeamVersusRow({required this.team1, required this.team2});

  final _TeamInfo team1;
  final _TeamInfo team2;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        _TeamAvatar(team: team1),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            team1.name,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'vs',
          style: textTheme.bodySmall?.copyWith(
            color: CricketSpiritColors.mutedForeground,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            team2.name,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _TeamAvatar(team: team2),
      ],
    );
  }
}

class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar({required this.team});

  final _TeamInfo team;

  @override
  Widget build(BuildContext context) {
    final initials =
        team.name.isNotEmpty ? team.name.trim().characters.first : '?';
    return CircleAvatar(
      radius: 16,
      backgroundColor: CricketSpiritColors.secondary,
      foregroundColor: CricketSpiritColors.foreground,
      child: Text(
        initials.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: CricketSpiritColors.foreground,
            ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: CricketSpiritColors.mutedForeground,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.tone});

  final String label;
  final _StatusTone tone;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;
    switch (tone) {
      case _StatusTone.success:
        background = CricketSpiritColors.primary.withOpacity(0.15);
        foreground = CricketSpiritColors.primary;
        break;
      case _StatusTone.warning:
        background = const Color(0xFFf59e0b).withOpacity(0.2);
        foreground = const Color(0xFFfbbf24);
        break;
      case _StatusTone.danger:
        background = CricketSpiritColors.error.withOpacity(0.15);
        foreground = CricketSpiritColors.error;
        break;
      case _StatusTone.neutral:
        background = CricketSpiritColors.white10;
        foreground = CricketSpiritColors.mutedForeground;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: foreground.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

enum _StatusTone { success, warning, danger, neutral }

_StatusTone _statusTone(String status) {
  switch (status.toUpperCase()) {
    case 'ACCEPTED':
    case 'SCHEDULED':
    case 'STARTED':
      return _StatusTone.success;
    case 'PENDING':
      return _StatusTone.warning;
    case 'REJECTED':
    case 'CANCELLED':
      return _StatusTone.danger;
    default:
      return _StatusTone.neutral;
  }
}

class _CreatedMatch {
  _CreatedMatch({
    required this.id,
    required this.status,
    required this.team1,
    required this.team2,
    required this.scheduledDate,
    required this.scorer,
    required this.invitations,
  });

  final String id;
  final String status;
  final _TeamInfo team1;
  final _TeamInfo team2;
  final DateTime? scheduledDate;
  final _ScorerInfo? scorer;
  final List<_InvitationSummary> invitations;

  String get scheduledDateLabel =>
      _formatDateTime(scheduledDate) ?? 'Not scheduled';

  factory _CreatedMatch.fromJson(Map<String, dynamic> json) {
    return _CreatedMatch(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'UNKNOWN',
      team1: _TeamInfo.fromJson(json['team1']),
      team2: _TeamInfo.fromJson(json['team2']),
      scheduledDate: _parseDate(json['scheduledDate']),
      scorer: _ScorerInfo.fromJsonNullable(json['scorer']),
      invitations: (json['scorerInvitations'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(_InvitationSummary.fromJson)
              .toList() ??
          const [],
    );
  }
}

class _InvitationSummary {
  _InvitationSummary({
    required this.id,
    required this.status,
    required this.scorerName,
  });

  final String id;
  final String status;
  final String scorerName;

  String get label => scorerName.isEmpty ? status : '$scorerName • $status';

  factory _InvitationSummary.fromJson(Map<String, dynamic> json) {
    final scorer = json['scorer'] as Map<String, dynamic>?;
    return _InvitationSummary(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      scorerName: scorer?['name']?.toString() ??
          scorer?['email']?.toString() ??
          '',
    );
  }
}

class _ScorerInvitation {
  _ScorerInvitation({
    required this.id,
    required this.status,
    required this.invitedAt,
    required this.match,
  });

  final String id;
  final String status;
  final DateTime? invitedAt;
  final _InvitationMatch match;

  String get invitedAtLabel => _formatDateTime(invitedAt) ?? 'Recently';

  factory _ScorerInvitation.fromJson(Map<String, dynamic> json) {
    return _ScorerInvitation(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      invitedAt: _parseDate(json['invitedAt']),
      match: _InvitationMatch.fromJson(json['match']),
    );
  }
}

class _TeamInvitation {
  _TeamInvitation({
    required this.id,
    required this.status,
    required this.invitedAt,
    required this.team,
    required this.match,
  });

  final String id;
  final String status;
  final DateTime? invitedAt;
  final _TeamInfo team;
  final _InvitationMatch match;

  String get invitedAtLabel => _formatDateTime(invitedAt) ?? 'Recently';

  factory _TeamInvitation.fromJson(Map<String, dynamic> json) {
    return _TeamInvitation(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      invitedAt: _parseDate(json['invitedAt']),
      team: _TeamInfo.fromJson(json['team']),
      match: _InvitationMatch.fromJson(json['match']),
    );
  }
}

class _CompactMatch {
  _CompactMatch({
    required this.id,
    required this.status,
    required this.team1,
    required this.team2,
    required this.scheduledDate,
    required this.scorer,
  });

  final String id;
  final String status;
  final _TeamInfo team1;
  final _TeamInfo team2;
  final DateTime? scheduledDate;
  final _ScorerInfo? scorer;

  String get scheduledDateLabel =>
      _formatDateTime(scheduledDate) ?? 'Not scheduled';

  factory _CompactMatch.fromJson(Map<String, dynamic> json) {
    return _CompactMatch(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'UNKNOWN',
      team1: _TeamInfo.fromJson(json['team1']),
      team2: _TeamInfo.fromJson(json['team2']),
      scheduledDate: _parseDate(json['scheduledDate']),
      scorer: _ScorerInfo.fromJsonNullable(json['scorer']),
    );
  }
}

class _InvitationMatch {
  _InvitationMatch({
    required this.team1,
    required this.team2,
    required this.tournamentName,
  });

  final _TeamInfo team1;
  final _TeamInfo team2;
  final String? tournamentName;

  factory _InvitationMatch.fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return _InvitationMatch(
      team1: _TeamInfo.fromJson(map['team1']),
      team2: _TeamInfo.fromJson(map['team2']),
      tournamentName: map['tournament']?['name']?.toString(),
    );
  }
}

class _TeamInfo {
  _TeamInfo({required this.id, required this.name});

  final String id;
  final String name;

  factory _TeamInfo.fromJson(dynamic json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return _TeamInfo(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Team',
    );
  }
}

class _ScorerInfo {
  _ScorerInfo({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  String get displayName => name.isNotEmpty ? name : email;

  static _ScorerInfo? fromJsonNullable(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    return _ScorerInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  final raw = value.toString();
  if (raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

String? _formatDateTime(DateTime? dateTime) {
  if (dateTime == null) return null;
  final local = dateTime.toLocal();
  final date =
      '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  final time =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  return '$date $time';
}
