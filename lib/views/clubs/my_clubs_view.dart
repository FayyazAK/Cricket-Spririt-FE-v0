import 'dart:ui';
import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/themes/themes.dart';
import '../../models/user_model.dart';
import '../../services/api/api_service.dart';
import 'club_view_page.dart';
import 'register_club_view.dart';

class MyClubsView extends StatefulWidget {
  const MyClubsView({super.key});

  @override
  State<MyClubsView> createState() => _MyClubsViewState();
}

class _MyClubsViewState extends State<MyClubsView> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await apiService.getCurrentUser();
      if (response['data'] != null) {
        final user = UserModel.fromJson(response['data']);
        appState.updateUser(user);
      }
    } catch (_) {
      // Ignore errors, just use cached data
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final user = appState.currentUser;
    final ownedClubs = user?.ownedClubs ?? [];

    return Scaffold(
      backgroundColor: CricketSpiritColors.background,
      appBar: AppBar(
        title: const Text('My Clubs'),
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
              onPressed: _refreshProfile,
            ),
        ],
      ),
      body: ownedClubs.isEmpty
          ? _buildEmptyState(textTheme)
          : RefreshIndicator(
              onRefresh: _refreshProfile,
              color: CricketSpiritColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ownedClubs.length,
                itemBuilder: (context, index) {
                  final club = ownedClubs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildClubCard(club, isOwner: true),
                  );
                },
              ),
            ),
      floatingActionButton: ownedClubs.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RegisterClubView(),
                  ),
                );
                if (result == true) {
                  await _refreshProfile();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Club'),
              backgroundColor: CricketSpiritColors.primary,
              foregroundColor: CricketSpiritColors.primaryForeground,
            ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: CricketSpiritColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.business_outlined,
                size: 48,
                color: CricketSpiritColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Clubs Yet',
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your own cricket club and start managing your team.',
              style: textTheme.bodyMedium?.copyWith(
                color: CricketSpiritColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RegisterClubView(),
                  ),
                );
                if (result == true) {
                  await _refreshProfile();
                }
              },
              icon: const Icon(Icons.add_business_outlined),
              label: const Text('Create a Club'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubCard(OwnedClub club, {required bool isOwner}) {
    final textTheme = Theme.of(context).textTheme;
    final logoUrl = club.profilePicture;
    final hasLogo = logoUrl != null && logoUrl.trim().isNotEmpty;

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

    final address = club.address;
    String location = '';
    if (address != null) {
      location = [
        address.city,
        address.state,
      ].where((s) => s.trim().isNotEmpty).join(', ');
    }

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClubViewPage(
              clubId: club.id,
              isOwner: isOwner,
            ),
          ),
        );
        if (result == true) {
          await _refreshProfile();
        }
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
                  width: 64,
                  height: 64,
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
                            width: 64,
                            height: 64,
                            headers: apiService.accessToken != null
                                ? <String, String>{
                                    'Authorization': 'Bearer ${apiService.accessToken}',
                                  }
                                : null,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.business_outlined,
                                color: CricketSpiritColors.primary,
                                size: 32,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.business_outlined,
                              color: CricketSpiritColors.primary,
                              size: 32,
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
                      Text(
                        club.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
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
                      const SizedBox(height: 8),
                      // Owner Badge
                      if (isOwner)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: CricketSpiritColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
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
                // Edit Icon for owners
                if (isOwner)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CricketSpiritColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: CricketSpiritColors.foreground,
                      size: 20,
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
