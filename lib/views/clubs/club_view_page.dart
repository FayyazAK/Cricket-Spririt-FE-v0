import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/themes/themes.dart';
import '../../services/api/api_service.dart';
import 'club_players_view.dart';
import 'invite_players_view.dart';

class ClubViewPage extends StatefulWidget {
  const ClubViewPage({
    super.key,
    required this.clubId,
    required this.isOwner,
  });

  final String clubId;
  final bool isOwner;

  @override
  State<ClubViewPage> createState() => _ClubViewPageState();
}

class _ClubViewPageState extends State<ClubViewPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  String? _error;
  Map<String, dynamic>? _clubData;

  // Club players (from club details response)
  List<Map<String, dynamic>> _clubPlayers = [];
  List<Map<String, dynamic>> _pendingPlayers = [];
  List<Map<String, dynamic>> _rejectedPlayers = [];
  int _totalPlayerCount = 0;
  int _maxPlayers = 20;
  int _pendingCount = 0;
  int _rejectedCount = 0;

  // For editing
  Map<String, List<String>> _citiesByProvince = {};
  List<String> _provinces = [];

  // Controllers
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _streetController = TextEditingController();
  final _townSuburbController = TextEditingController();
  final _postalCodeController = TextEditingController();

  String? _selectedProvince;
  String? _selectedCity;
  DateTime? _establishedDate;
  String? _profilePictureUrl;
  File? _profilePictureFile;

  @override
  void initState() {
    super.initState();
    _fetchClubDetails();
    _loadPakistanCities();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _streetController.dispose();
    _townSuburbController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadPakistanCities() async {
    try {
      final raw = await rootBundle.loadString('assets/cities_by_province.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      final map = <String, List<String>>{};
      final provinces = <String>[];

      for (final entry in decoded.entries) {
        provinces.add(entry.key);
        final list = (entry.value as List)
            .map((e) => (e as Map<String, dynamic>)['name'] as String)
            .toList();
        final unique = list.toSet().toList()..sort();
        map[entry.key] = unique;
      }

      provinces.sort();

      if (!mounted) return;
      setState(() {
        _citiesByProvince = map;
        _provinces = provinces;
      });
    } catch (_) {
      // Ignore
    }
  }

  Future<void> _fetchClubDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await apiService.getClubById(widget.clubId);
      if (response['data'] != null) {
        _clubData = response['data'] as Map<String, dynamic>;
        _populateFields();
        _extractPlayersData();
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _extractPlayersData() {
    if (_clubData == null) return;

    // Extract club players
    final clubPlayers = (_clubData!['clubPlayers'] as List?) ?? [];
    _clubPlayers = clubPlayers.cast<Map<String, dynamic>>();

    // Extract pending players (only for owner)
    final pendingPlayers = (_clubData!['pendingPlayers'] as List?) ?? [];
    _pendingPlayers = pendingPlayers.cast<Map<String, dynamic>>();

    // Extract rejected players (only for owner)
    final rejectedPlayers = (_clubData!['rejectedPlayers'] as List?) ?? [];
    _rejectedPlayers = rejectedPlayers.cast<Map<String, dynamic>>();

    // Extract player stats
    final playerStats = _clubData!['playerStats'] as Map<String, dynamic>?;
    if (playerStats != null) {
      _totalPlayerCount = (playerStats['total'] as num?)?.toInt() ?? _clubPlayers.length;
      _maxPlayers = (playerStats['maxPlayers'] as num?)?.toInt() ?? 20;
      _pendingCount = (playerStats['pending'] as num?)?.toInt() ?? _pendingPlayers.length;
      _rejectedCount = (playerStats['rejected'] as num?)?.toInt() ?? _rejectedPlayers.length;
    } else {
      _totalPlayerCount = _clubPlayers.length;
      _maxPlayers = 20;
      _pendingCount = _pendingPlayers.length;
      _rejectedCount = _rejectedPlayers.length;
    }
  }

  void _populateFields() {
    if (_clubData == null) return;

    _nameController.text = _clubData!['name'] ?? '';
    _bioController.text = _clubData!['bio'] ?? '';
    _profilePictureUrl = _clubData!['profilePicture'];

    if (_clubData!['establishedDate'] != null) {
      _establishedDate = DateTime.tryParse(_clubData!['establishedDate']);
    }

    final address = _clubData!['address'] as Map<String, dynamic>?;
    if (address != null) {
      _streetController.text = address['street'] ?? '';
      _townSuburbController.text = address['townSuburb'] ?? '';
      _postalCodeController.text = address['postalCode'] ?? '';
      _selectedProvince = address['state'];
      _selectedCity = address['city'];
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

  Future<void> _pickAndCropImage(ImageSource source) async {
    try {
      bool hasPermission = false;

      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        hasPermission = status.isGranted || status.isLimited;
      } else {
        final status = await Permission.photos.request();
        if (!status.isGranted && !status.isLimited) {
          final storageStatus = await Permission.storage.request();
          hasPermission = storageStatus.isGranted || storageStatus.isLimited;
        } else {
          hasPermission = true;
        }
      }

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission required to access photos'),
              backgroundColor: CricketSpiritColors.error,
            ),
          );
        }
        return;
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      try {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Club Logo',
              toolbarColor: CricketSpiritColors.primary,
              toolbarWidgetColor: Colors.white,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Crop Club Logo',
              aspectRatioLockEnabled: true,
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _profilePictureFile = File(croppedFile.path);
          });
        }
      } catch (_) {
        setState(() {
          _profilePictureFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: CricketSpiritColors.error,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndCropImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndCropImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectEstablishedDate() async {
    final now = DateTime.now();
    final initialDate = _establishedDate ?? DateTime(now.year - 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: CricketSpiritColors.primary,
              onPrimary: CricketSpiritColors.primaryForeground,
              surface: CricketSpiritColors.card,
              onSurface: CricketSpiritColors.foreground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _establishedDate = picked);
    }
  }

  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      // Upload new logo if selected
      String? newLogoPath = _profilePictureUrl;
      if (_profilePictureFile != null) {
        final uploadResponse = await apiService.uploadClubProfilePicture(
          _profilePictureFile!.path,
        );
        newLogoPath = uploadResponse['data']['filePath'];
      }

      await apiService.updateClub(
        id: widget.clubId,
        name: _nameController.text.trim(),
        profilePicture: newLogoPath,
        bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
        establishedDate: _establishedDate?.toIso8601String().split('T')[0],
        address: {
          if (_streetController.text.trim().isNotEmpty)
            'street': _streetController.text.trim(),
          if (_townSuburbController.text.trim().isNotEmpty)
            'townSuburb': _townSuburbController.text.trim(),
          'city': _selectedCity ?? '',
          'state': _selectedProvince ?? '',
          'country': 'Pakistan',
          if (_postalCodeController.text.trim().isNotEmpty)
            'postalCode': _postalCodeController.text.trim(),
        },
      );

      setState(() {
        _isSaving = false;
        _isEditing = false;
        _profilePictureFile = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Club updated successfully!'),
            backgroundColor: CricketSpiritColors.primary,
          ),
        );
        // Refresh data
        await _fetchClubDetails();
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: CricketSpiritColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: CricketSpiritColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Club' : 'Club Details'),
        actions: [
          if (widget.isOwner && !_isLoading && _clubData != null)
            if (_isEditing)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _profilePictureFile = null;
                    _populateFields();
                  });
                },
                child: const Text('Cancel'),
              )
            else
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => setState(() => _isEditing = true),
              ),
        ],
      ),
      body: _buildBody(textTheme),
      bottomNavigationBar: _isEditing
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: CricketSpiritColors.primaryForeground,
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            )
          : null,
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
                'Failed to load club',
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
                onPressed: _fetchClubDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_clubData == null) {
      return const Center(
        child: Text('Club not found'),
      );
    }

    if (_isEditing) {
      return _buildEditForm(textTheme);
    }

    return _buildViewMode(textTheme);
  }

  void _navigateToInvitePlayers() async {
    final acceptedIds = _clubPlayers
        .map((p) => p['id']?.toString())
        .whereType<String>()
        .toSet();
    final pendingIds = _pendingPlayers
        .map((p) => p['id']?.toString())
        .whereType<String>()
        .toSet();
    final rejectedIds = _rejectedPlayers
        .map((p) => p['id']?.toString())
        .whereType<String>()
        .toSet();

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => InvitePlayersView(
          clubId: widget.clubId,
          clubName: _clubData!['name'] ?? 'Club',
          currentPlayerCount: _totalPlayerCount + _pendingCount,
          maxPlayers: _maxPlayers,
          existingPlayerIds: acceptedIds,
          pendingPlayerIds: pendingIds,
          rejectedPlayerIds: rejectedIds,
        ),
      ),
    );

    if (result == true) {
      _fetchClubDetails();
    }
  }

  void _navigateToClubPlayers() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClubPlayersView(
          clubId: widget.clubId,
          clubName: _clubData!['name'] ?? 'Club',
          isOwner: widget.isOwner,
          clubPlayers: _clubPlayers,
          pendingPlayers: _pendingPlayers,
          rejectedPlayers: _rejectedPlayers,
          totalCount: _totalPlayerCount,
          maxPlayers: _maxPlayers,
        ),
      ),
    );
  }

  Widget _buildViewMode(TextTheme textTheme) {
    final logoUrl = _getFullImageUrl(_clubData!['profilePicture']);
    final address = _clubData!['address'] as Map<String, dynamic>?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Club Header
          _buildGlassmorphicCard(
            child: Column(
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: CricketSpiritColors.primary.withOpacity(0.15),
                    border: Border.all(
                      color: CricketSpiritColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: logoUrl != null
                        ? Image.network(
                            logoUrl,
                            fit: BoxFit.cover,
                            headers: apiService.accessToken != null
                                ? {'Authorization': 'Bearer ${apiService.accessToken}'}
                                : null,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.business_outlined,
                              size: 48,
                              color: CricketSpiritColors.primary,
                            ),
                          )
                        : const Icon(
                            Icons.business_outlined,
                            size: 48,
                            color: CricketSpiritColors.primary,
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Name
                Text(
                  _clubData!['name'] ?? 'Unknown Club',
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Owner badge
                if (widget.isOwner)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: CricketSpiritColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          size: 16,
                          color: CricketSpiritColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'You are the owner',
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
          const SizedBox(height: 16),

          // Bio
          if ((_clubData!['bio'] ?? '').toString().trim().isNotEmpty)
            _buildGlassmorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _clubData!['bio'],
                    style: textTheme.bodyMedium?.copyWith(
                      color: CricketSpiritColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          if ((_clubData!['bio'] ?? '').toString().trim().isNotEmpty)
            const SizedBox(height: 16),

          // Details
          _buildGlassmorphicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Details',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                if (_clubData!['establishedDate'] != null)
                  _infoRow(
                    Icons.calendar_today_outlined,
                    'Established',
                    _formatDate(_clubData!['establishedDate']),
                  ),
                if (address != null) ...[
                  _infoRow(
                    Icons.location_on_outlined,
                    'Location',
                    [
                      address['city'],
                      address['state'],
                      address['country'],
                    ].where((s) => s != null && s.toString().trim().isNotEmpty).join(', '),
                  ),
                  if ((address['street'] ?? '').toString().trim().isNotEmpty)
                    _infoRow(
                      Icons.home_outlined,
                      'Address',
                      [
                        address['street'],
                        address['townSuburb'],
                        address['postalCode'],
                      ].where((s) => s != null && s.toString().trim().isNotEmpty).join(', '),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Club Players Section
          _buildGlassmorphicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Players',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: CricketSpiritColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_totalPlayerCount/$_maxPlayers',
                        style: textTheme.bodySmall?.copyWith(
                          color: CricketSpiritColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Player Category Cards
                _buildPlayerCategoryCard(
                  icon: Icons.people,
                  label: 'Club Players',
                  count: _totalPlayerCount,
                  color: CricketSpiritColors.primary,
                  onTap: _navigateToClubPlayers,
                ),
                if (widget.isOwner) ...[
                  const SizedBox(height: 10),
                  _buildPlayerCategoryCard(
                    icon: Icons.mail_outline,
                    label: 'Invited Players',
                    count: _pendingCount,
                    color: Colors.orange,
                    onTap: _navigateToClubPlayers,
                  ),
                  const SizedBox(height: 10),
                  _buildPlayerCategoryCard(
                    icon: Icons.person_off_outlined,
                    label: 'Rejected Players',
                    count: _rejectedCount,
                    color: CricketSpiritColors.error,
                    onTap: _navigateToClubPlayers,
                  ),
                ],

                if (widget.isOwner && (_totalPlayerCount + _pendingCount) < _maxPlayers) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _navigateToInvitePlayers,
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text('Add Players'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCategoryCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: CricketSpiritColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(TextTheme textTheme) {
    final currentLogoUrl = _getFullImageUrl(_profilePictureUrl);
    final hasLocalPhoto = _profilePictureFile != null;
    final hasRemotePhoto = currentLogoUrl != null;

    ImageProvider? logoImage;
    if (hasLocalPhoto) {
      logoImage = FileImage(_profilePictureFile!);
    } else if (hasRemotePhoto) {
      logoImage = NetworkImage(currentLogoUrl);
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Logo
            _buildGlassmorphicCard(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: CricketSpiritColors.primary.withOpacity(0.15),
                        border: Border.all(
                          color: CricketSpiritColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: logoImage != null
                            ? Image(
                                image: logoImage,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              )
                            : const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: CricketSpiritColors.mutedForeground,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _showImageSourceDialog,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Change Logo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Club Details
            _buildGlassmorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Club Details',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Club name *',
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Club name is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'About the club',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _selectEstablishedDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Established date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _establishedDate != null
                            ? '${_establishedDate!.day}/${_establishedDate!.month}/${_establishedDate!.year}'
                            : 'Select date',
                        style: TextStyle(
                          color: _establishedDate != null
                              ? CricketSpiritColors.foreground
                              : CricketSpiritColors.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Address
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _streetController,
                    decoration: const InputDecoration(
                      labelText: 'Street address',
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _townSuburbController,
                    decoration: const InputDecoration(
                      labelText: 'Area / town / suburb',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _selectedProvince,
                    isExpanded: true,
                    items: _provinces
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedProvince = v;
                        _selectedCity = null;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Province / state *',
                      prefixIcon: Icon(Icons.map_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Province is required' : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    isExpanded: true,
                    items: (_selectedProvince == null)
                        ? []
                        : (_citiesByProvince[_selectedProvince] ?? [])
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                    onChanged: (v) => setState(() => _selectedCity = v),
                    decoration: const InputDecoration(
                      labelText: 'City *',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'City is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _postalCodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Postal code',
                      prefixIcon: Icon(Icons.markunread_mailbox),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80), // Space for bottom button
          ],
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

  Widget _infoRow(IconData icon, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: CricketSpiritColors.mutedForeground,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: CricketSpiritColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
