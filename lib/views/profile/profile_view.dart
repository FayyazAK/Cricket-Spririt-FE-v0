import 'dart:ui';
import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/routes.dart';
import '../../app/themes/themes.dart';
import '../../models/user_model.dart';
import '../../services/api/api_service.dart';
import '../clubs/register_club_view.dart';
import '../players/club_invitations_view.dart';
import '../players/register_player_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await apiService.getCurrentUser();
      
      if (response['data'] != null) {
        final userJson = response['data'];
        final user = UserModel.fromJson(userJson);
        appState.updateUser(user);
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = appState.currentUser;
    final isPlayerRole = (user?.role ?? '').toUpperCase() == 'PLAYER';
    final rawPhotoUrl = isPlayerRole ? user?.player?.profilePicture : null;
    final playerPhotoUrl =
        (rawPhotoUrl != null && rawPhotoUrl.trim().isNotEmpty) ? rawPhotoUrl.trim() : null;

    // Show loading or error states
    if (_isLoading && user == null) {
      return Scaffold(
        backgroundColor: CricketSpiritColors.background,
        appBar: AppBar(
          backgroundColor: CricketSpiritColors.background,
          title: Text(
            'Profile',
            style: textTheme.displaySmall?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: CricketSpiritColors.primary,
          ),
        ),
      );
    }

    if (_error != null && user == null) {
      return Scaffold(
        backgroundColor: CricketSpiritColors.background,
        appBar: AppBar(
          backgroundColor: CricketSpiritColors.background,
          title: Text(
            'Profile',
            style: textTheme.displaySmall?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: Center(
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
                  'Failed to load profile',
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
                  onPressed: _fetchProfile,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show user data
    return Scaffold(
      backgroundColor: CricketSpiritColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: CricketSpiritColors.background,
            elevation: 0,
            title: Text(
              'Profile',
              style: textTheme.displaySmall?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
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
                  onPressed: _fetchProfile,
                ),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Header Card with Glassmorphism
                  _buildGlassmorphicCard(
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // No glow/shadow around avatar
                            color: playerPhotoUrl != null
                                ? Colors.transparent
                                : CricketSpiritColors.primary,
                          ),
                          child: ClipOval(
                            child: playerPhotoUrl != null
                                ? Image.network(
                                    playerPhotoUrl,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                    // If your backend protects uploads, send bearer token.
                                    headers: apiService.accessToken != null
                                        ? <String, String>{
                                            'Authorization':
                                                'Bearer ${apiService.accessToken}',
                                          }
                                        : null,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          user?.getInitials() ?? 'U',
                                          style: textTheme.displayLarge?.copyWith(
                                            color: CricketSpiritColors.primaryForeground,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Text(
                                      user?.getInitials() ?? 'U',
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
                          user?.name ?? 'User',
                          style: textTheme.displaySmall?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Email
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              size: 16,
                              color: CricketSpiritColors.mutedForeground,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user?.email ?? '',
                              style: textTheme.bodyMedium?.copyWith(
                                color: CricketSpiritColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: CricketSpiritColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: CricketSpiritColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            (user?.role ?? 'USER').toUpperCase(),
                            style: textTheme.labelLarge?.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Member Since
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: CricketSpiritColors.mutedForeground,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Member since ${user?.getMemberSince() ?? 'Unknown'}',
                              style: textTheme.bodySmall?.copyWith(
                                color: CricketSpiritColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Player Profile
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'PLAYER PROFILE',
                      style: textTheme.labelLarge?.copyWith(
                        fontSize: 12,
                        color: CricketSpiritColors.mutedForeground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPlayerProfileSection(user),
                  // Club Invitations Button (only for players)
                  if ((user?.role ?? '').toUpperCase() == 'PLAYER' && user?.player != null)
                    _buildClubInvitationsButton(),
                  const SizedBox(height: 24),
                  // My Clubs Section
                  _buildMyClubsSection(user),
                  const SizedBox(height: 24),
                  // Logout Button with Glassmorphism
                  _buildGlassmorphicCard(
                    color: Colors.red.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: InkWell(
                      onTap: () {
                        _showLogoutDialog(context);
                      },
                      borderRadius: BorderRadius.circular(
                        CricketSpiritRadius.card,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout,
                            color: Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Logout',
                            style: textTheme.bodyLarge?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicCard({
    required Widget child,
    Color? color,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? CricketSpiritColors.card.withOpacity(0.7),
            borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
            border: Border.all(
              color: CricketSpiritColors.border.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  Widget _buildPlayerProfileSection(UserModel? user) {
    final textTheme = Theme.of(context).textTheme;
    final player = user?.player;
    final isPlayerRole = (user?.role ?? '').toUpperCase() == 'PLAYER';
    final hasProfile = isPlayerRole && player != null;

    // If role is PLAYER, user should not see the "create player profile" CTA.
    if (!hasProfile) {
      if (isPlayerRole) {
        return _buildGlassmorphicCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Player profile not available',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Pull to refresh or tap refresh to reload your profile.',
                style: textTheme.bodyMedium?.copyWith(
                  color: CricketSpiritColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _fetchProfile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ),
            ],
          ),
        );
      }

      return _buildGlassmorphicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No player profile yet',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Create your player profile to show your cricket details.',
              style: textTheme.bodyMedium?.copyWith(
                color: CricketSpiritColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RegisterPlayerView(),
                    ),
                  );
                  if (result == true) {
                    await _fetchProfile();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Create player profile'),
              ),
            ),
          ],
        ),
      );
    }

    final dob = '${player.dateOfBirth.day}/${player.dateOfBirth.month}/${player.dateOfBirth.year}';
    final bowlingTypes = player.bowlingTypes;

    return _buildGlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${player.firstName} ${player.lastName}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RegisterPlayerView(existingPlayer: player),
                    ),
                  );
                  if (result == true) {
                    await _fetchProfile();
                  }
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow('Gender', player.gender),
          _infoRow('Date of birth', dob),
          _infoRow('Player type', player.playerType),
          _infoRow('Wicket keeper', player.isWicketKeeper ? 'Yes' : 'No'),
          _infoRow('Batting hand', player.batHand),
          if (player.playerType != 'BATSMAN')
            _infoRow('Bowling hand', player.bowlHand ?? '—'),
          const SizedBox(height: 10),
          Text(
            'Address',
            style: textTheme.labelLarge?.copyWith(
              color: CricketSpiritColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            [
              if ((player.address.street ?? '').trim().isNotEmpty) player.address.street!.trim(),
              if ((player.address.townSuburb ?? '').trim().isNotEmpty) player.address.townSuburb!.trim(),
              player.address.city,
              player.address.state,
              player.address.country,
              if ((player.address.postalCode ?? '').trim().isNotEmpty) player.address.postalCode!.trim(),
            ].join(', '),
            style: textTheme.bodyMedium,
          ),
          if (player.playerType != 'BATSMAN') ...[
            const SizedBox(height: 12),
            Text(
              'Bowling types',
              style: textTheme.labelLarge?.copyWith(
                color: CricketSpiritColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 8),
            if (bowlingTypes.isEmpty)
              Text('—', style: textTheme.bodyMedium)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: bowlingTypes
                    .map(
                      (t) => Chip(
                        label: Text(t.shortName),
                        backgroundColor: CricketSpiritColors.primary.withOpacity(0.15),
                        side: BorderSide(
                          color: CricketSpiritColors.primary.withOpacity(0.25),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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

  Widget _buildClubInvitationsButton() {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: _buildGlassmorphicCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ClubInvitationsView(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(CricketSpiritRadius.card),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.mail_outline,
                  color: Colors.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Club Invitations',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'View and respond to club invitations',
                      style: textTheme.bodySmall?.copyWith(
                        color: CricketSpiritColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: CricketSpiritColors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyClubsSection(UserModel? user) {
    final textTheme = Theme.of(context).textTheme;
    final ownedClubs = user?.ownedClubs ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MY CLUBS',
              style: textTheme.labelLarge?.copyWith(
                fontSize: 12,
                color: CricketSpiritColors.mutedForeground,
              ),
            ),
            if (ownedClubs.isEmpty)
              TextButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RegisterClubView(),
                    ),
                  );
                  if (result == true) {
                    await _fetchProfile();
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (ownedClubs.isEmpty)
          _buildGlassmorphicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No clubs yet',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create your own cricket club and start managing your team.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: CricketSpiritColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterClubView(),
                        ),
                      );
                      if (result == true) {
                        await _fetchProfile();
                      }
                    },
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('Create a Club'),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: ownedClubs
                .map((club) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildClubCard(club),
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildClubCard(OwnedClub club) {
    final textTheme = Theme.of(context).textTheme;
    final logoUrl = club.profilePicture;
    final hasLogo = logoUrl != null && logoUrl.trim().isNotEmpty;

    // Build full URL for logo
    String? fullLogoUrl;
    if (hasLogo) {
      final trimmed = logoUrl.trim();
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        fullLogoUrl = trimmed;
      } else {
        final host = ApiService.baseUrl.split('/api/v1').first;
        fullLogoUrl = '$host/$trimmed';
      }
    }

    // Build location string
    final address = club.address;
    String location = '';
    if (address != null) {
      location = [
        address.city,
        address.state,
      ].where((s) => s.trim().isNotEmpty).join(', ');
    }

    return GestureDetector(
      onTap: () {
        // TODO: Navigate to club details when implemented
      },
      child: ClipRRect(
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Club Logo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: CricketSpiritColors.primary.withOpacity(0.15),
                    border: Border.all(
                      color: CricketSpiritColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: fullLogoUrl != null
                        ? Image.network(
                            fullLogoUrl,
                            fit: BoxFit.cover,
                            width: 56,
                            height: 56,
                            headers: apiService.accessToken != null
                                ? <String, String>{
                                    'Authorization': 'Bearer ${apiService.accessToken}',
                                  }
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
                const SizedBox(width: 16),
                // Club Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Club Name
                      Text(
                        club.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Location
                      if (location.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: CricketSpiritColors.mutedForeground,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                location,
                                style: textTheme.bodySmall?.copyWith(
                                  color: CricketSpiritColors.mutedForeground,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Owner Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CricketSpiritColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_outlined,
                        size: 14,
                        color: CricketSpiritColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Owner',
                        style: textTheme.bodySmall?.copyWith(
                          color: CricketSpiritColors.primary,
                          fontWeight: FontWeight.w600,
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

  void _showLogoutDialog(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CricketSpiritRadius.dialog),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: CricketSpiritColors.card.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(
                      CricketSpiritRadius.dialog,
                    ),
                    border: Border.all(
                      color: CricketSpiritColors.border.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Title
                      Text(
                        'Logout',
                        style: textTheme.displaySmall?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Message
                      Text(
                        'Are you sure you want to logout?',
                        style: textTheme.bodyMedium?.copyWith(
                          color: CricketSpiritColors.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.of(dialogContext).pop();
                                final navigator = Navigator.of(context);
                                await appState.logout();
                                if (!mounted) return;
                                navigator.pushNamedAndRemoveUntil(
                                  AppRoutes.login,
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
