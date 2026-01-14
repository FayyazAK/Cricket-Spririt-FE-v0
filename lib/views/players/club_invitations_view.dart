import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/themes/themes.dart';
import '../../services/api/api_service.dart';
import '../clubs/club_view_page.dart';

class ClubInvitationsView extends StatefulWidget {
  const ClubInvitationsView({super.key});

  @override
  State<ClubInvitationsView> createState() => _ClubInvitationsViewState();
}

class _ClubInvitationsViewState extends State<ClubInvitationsView> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _invitations = [];

  @override
  void initState() {
    super.initState();
    _fetchInvitations();
  }

  Future<void> _fetchInvitations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await apiService.getMyClubInvitations();
      final data = (response['data'] as List?) ?? [];
      setState(() {
        _invitations = data.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _acceptInvitation(String invitationId, String clubName) async {
    final confirmed = await _showConfirmDialog(
      title: 'Accept Invitation',
      message: 'Are you sure you want to join "$clubName"?',
      confirmText: 'Accept',
      confirmColor: CricketSpiritColors.primary,
    );

    if (confirmed != true) return;

    _showLoadingDialog();

    try {
      await apiService.acceptClubInvitation(invitationId);
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You have joined "$clubName"!'),
          backgroundColor: CricketSpiritColors.primary,
        ),
      );

      _fetchInvitations();
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: CricketSpiritColors.error,
        ),
      );
    }
  }

  Future<void> _rejectInvitation(String invitationId, String clubName) async {
    final confirmed = await _showConfirmDialog(
      title: 'Reject Invitation',
      message: 'Are you sure you want to reject the invitation from "$clubName"?',
      confirmText: 'Reject',
      confirmColor: CricketSpiritColors.error,
    );

    if (confirmed != true) return;

    _showLoadingDialog();

    try {
      await apiService.rejectClubInvitation(invitationId);
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invitation from "$clubName" rejected'),
          backgroundColor: CricketSpiritColors.mutedForeground,
        ),
      );

      _fetchInvitations();
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: CricketSpiritColors.error,
        ),
      );
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: CricketSpiritColors.card,
          title: Text(title),
          content: Text(
            message,
            style: TextStyle(color: CricketSpiritColors.mutedForeground),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
              ),
              child: Text(
                confirmText,
                style: TextStyle(
                  color: confirmColor == CricketSpiritColors.primary
                      ? CricketSpiritColors.primaryForeground
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: const Center(
          child: CircularProgressIndicator(
            color: CricketSpiritColors.primary,
          ),
        ),
      ),
    );
  }

  void _navigateToClubDetails(String clubId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClubViewPage(
          clubId: clubId,
          isOwner: false,
        ),
      ),
    );
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getTimeRemaining(String? expiresAt) {
    if (expiresAt == null) return '';
    final expiry = DateTime.tryParse(expiresAt);
    if (expiry == null) return '';

    final now = DateTime.now();
    final difference = expiry.difference(now);

    if (difference.isNegative) return 'Expired';
    if (difference.inDays > 0) return '${difference.inDays}d left';
    if (difference.inHours > 0) return '${difference.inHours}h left';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m left';
    return 'Expiring soon';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: CricketSpiritColors.background,
      appBar: AppBar(
        title: const Text('Club Invitations'),
        backgroundColor: CricketSpiritColors.background,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchInvitations,
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
                'Failed to load invitations',
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
              ElevatedButton.icon(
                onPressed: _fetchInvitations,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_invitations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mail_outline,
                size: 72,
                color: CricketSpiritColors.mutedForeground.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Pending Invitations',
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'When a club invites you to join, it will appear here.',
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

    return RefreshIndicator(
      onRefresh: _fetchInvitations,
      color: CricketSpiritColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _invitations.length,
        itemBuilder: (context, index) {
          final invitation = _invitations[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _InvitationCard(
              invitation: invitation,
              onTap: () {
                final clubId = invitation['club']?['id'];
                if (clubId != null) {
                  _navigateToClubDetails(clubId);
                }
              },
              onAccept: () {
                final invitationId = invitation['id'];
                final clubName = invitation['club']?['name'] ?? 'Club';
                if (invitationId != null) {
                  _acceptInvitation(invitationId, clubName);
                }
              },
              onReject: () {
                final invitationId = invitation['id'];
                final clubName = invitation['club']?['name'] ?? 'Club';
                if (invitationId != null) {
                  _rejectInvitation(invitationId, clubName);
                }
              },
              getFullImageUrl: _getFullImageUrl,
              formatDate: _formatDate,
              getTimeRemaining: _getTimeRemaining,
            ),
          );
        },
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
    required this.getFullImageUrl,
    required this.formatDate,
    required this.getTimeRemaining,
  });

  final Map<String, dynamic> invitation;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final String? Function(String?) getFullImageUrl;
  final String Function(String?) formatDate;
  final String Function(String?) getTimeRemaining;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final club = invitation['club'] as Map<String, dynamic>?;
    final clubName = club?['name'] ?? 'Unknown Club';
    final clubLogoUrl = getFullImageUrl(club?['profilePicture']);
    final ownerName = club?['owner']?['name'] ?? 'Unknown';
    final invitedAt = formatDate(invitation['invitedAt']);
    final timeRemaining = getTimeRemaining(invitation['invitationExpiresAt']);
    final isExpiringSoon = timeRemaining.contains('h') || 
                           timeRemaining.contains('m') || 
                           timeRemaining == 'Expiring soon';

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: CricketSpiritColors.card.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: CricketSpiritColors.border.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Card Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Club Logo
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: CricketSpiritColors.primary.withOpacity(0.15),
                          border: Border.all(
                            color: CricketSpiritColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: clubLogoUrl != null
                              ? Image.network(
                                  clubLogoUrl,
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                  headers: apiService.accessToken != null
                                      ? {'Authorization': 'Bearer ${apiService.accessToken}'}
                                      : null,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.business_outlined,
                                      color: CricketSpiritColors.primary,
                                      size: 28,
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.business_outlined,
                                    color: CricketSpiritColors.primary,
                                    size: 28,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Club Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clubName,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: CricketSpiritColors.mutedForeground,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Invited by $ownerName',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: CricketSpiritColors.mutedForeground,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 14,
                                  color: CricketSpiritColors.mutedForeground,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  invitedAt,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: CricketSpiritColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Time Remaining Badge
                      if (timeRemaining.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isExpiringSoon
                                ? Colors.orange.withOpacity(0.15)
                                : CricketSpiritColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: isExpiringSoon
                                    ? Colors.orange
                                    : CricketSpiritColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                timeRemaining,
                                style: textTheme.bodySmall?.copyWith(
                                  color: isExpiringSoon
                                      ? Colors.orange
                                      : CricketSpiritColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                // Divider
                Container(
                  height: 1,
                  color: CricketSpiritColors.border.withOpacity(0.3),
                ),
                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // View Club Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onTap,
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('View Club'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Reject Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReject,
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CricketSpiritColors.error,
                            side: BorderSide(
                              color: CricketSpiritColors.error.withOpacity(0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Accept Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onAccept,
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Accept'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
