import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/app_state.dart';
import '../../app/themes/themes.dart';
import '../../models/bowling_type_model.dart';
import '../../models/player_model.dart';
import '../../services/api/api_service.dart';
import '../../services/storage/storage_service.dart';

class RegisterPlayerView extends StatefulWidget {
  const RegisterPlayerView({
    super.key,
    this.existingPlayer,
  });

  final Player? existingPlayer;

  @override
  State<RegisterPlayerView> createState() => _RegisterPlayerViewState();
}

class _RegisterPlayerViewState extends State<RegisterPlayerView> {
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;
  bool _isLoading = false;
  bool _isFetchingBowlingTypes = true;
  bool _isLoadingPakistanCities = true;
  List<BowlingType> _bowlingTypes = [];
  List<String> _selectedBowlingTypeIds = [];
  Map<String, List<String>> _citiesByProvince = {};
  List<String> _provinces = [];
  String? _selectedProvince;
  String? _selectedCity;
  String? _prefilledProvince;
  String? _prefilledCity;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _streetController = TextEditingController();
  final _townSuburbController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // Form values
  String _gender = 'MALE';
  DateTime? _dateOfBirth;
  String _playerType = 'BATSMAN';
  bool _isWicketKeeper = false;
  String _batHand = 'RIGHT';
  String? _bowlHand = 'RIGHT';
  String? _profilePictureUrl;
  File? _profilePictureFile;

  @override
  void initState() {
    super.initState();
    _prefillFromExistingPlayer();
    _fetchBowlingTypes();
    _loadPakistanCities();
    _countryController.text = 'Pakistan';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillNameFromUser();
    });
  }

  bool get _isEdit => widget.existingPlayer != null;

  String? _absoluteImageUrl(String? url) {
    if (url == null) return null;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    // Backend returns paths like "/uploads/...". Derive host from baseUrl.
    final host = ApiService.baseUrl.split('/api/v1').first;
    return '$host$trimmed';
  }

  void _prefillFromExistingPlayer() {
    final player = widget.existingPlayer;
    if (player == null) return;

    _firstNameController.text = player.firstName;
    _lastNameController.text = player.lastName;
    _gender = player.gender;
    _dateOfBirth = player.dateOfBirth;
    _playerType = player.playerType;
    _isWicketKeeper = player.isWicketKeeper;
    _batHand = player.batHand;
    _bowlHand = player.bowlHand;
    _profilePictureUrl = _absoluteImageUrl(player.profilePicture);

    _selectedBowlingTypeIds =
        player.bowlingTypes.map((e) => e.id).whereType<String>().toList();

    // Address
    _streetController.text = player.address.street ?? '';
    _townSuburbController.text = player.address.townSuburb ?? '';
    _postalCodeController.text = player.address.postalCode ?? '';
    // Don't set dropdown values until the cities/provinces data is loaded,
    // otherwise DropdownButtonFormField will assert when items are still empty.
    _prefilledProvince = player.address.state;
    _prefilledCity = player.address.city;
    _stateController.text = player.address.state;
    _cityController.text = player.address.city;
    _countryController.text = player.address.country;
  }

  Future<void> _prefillNameFromUser() async {
    // Don't override if user already typed something.
    if (_firstNameController.text.trim().isNotEmpty ||
        _lastNameController.text.trim().isNotEmpty) {
      return;
    }

    // Prefer in-memory app state; fall back to storage (in case currentUser is null).
    final storedUser = appState.currentUser ?? await storageService.getUser();
    final fullName = storedUser?.name.trim();
    if (fullName == null || fullName.isEmpty) return;
    // Avoid prefilling placeholder/default values.
    if (fullName.toLowerCase() == 'user') return;
    if (fullName.contains('@')) return; // likely email

    final normalized = fullName.replaceAll(RegExp(r'\s+'), ' ');
    final parts = normalized.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return;

    _firstNameController.text = parts.first;
    _lastNameController.text = parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _streetController.dispose();
    _townSuburbController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _fetchBowlingTypes() async {
    setState(() => _isFetchingBowlingTypes = true);
    
    try {
      final response = await apiService.getBowlingTypes();
      final types = (response['data'] as List)
          .map((e) => BowlingType.fromJson(e as Map<String, dynamic>))
          .toList();
      
      if (mounted) {
        setState(() {
          _bowlingTypes = types;
          _isFetchingBowlingTypes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingBowlingTypes = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load bowling types: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: CricketSpiritColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _fetchBowlingTypes,
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadPakistanCities() async {
    setState(() => _isLoadingPakistanCities = true);
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
        // De-dup and sort for nicer UX
        final unique = list.toSet().toList()..sort();
        map[entry.key] = unique;
      }

      provinces.sort();

      if (!mounted) return;
      setState(() {
        _citiesByProvince = map;
        _provinces = provinces;
        _isLoadingPakistanCities = false;

        // Apply prefilled dropdown selections (edit mode) once data is available.
        if (_selectedProvince == null &&
            _prefilledProvince != null &&
            _provinces.contains(_prefilledProvince)) {
          _selectedProvince = _prefilledProvince;
        }
        if (_selectedProvince != null && _selectedCity == null && _prefilledCity != null) {
          final cities = _citiesByProvince[_selectedProvince] ?? const <String>[];
          if (cities.contains(_prefilledCity)) {
            _selectedCity = _prefilledCity;
          }
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingPakistanCities = false);
      // Keep UI usable; user can still type if needed (we'll show retry state).
    }
  }

  Future<bool> _requestPermission(Permission permission, String permissionName) async {
    final status = await permission.request();
    
    if (status.isGranted || status.isLimited) {
      return true;
    } else if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$permissionName permission is required'),
            backgroundColor: CricketSpiritColors.error,
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
      return false;
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionDialog(permissionName);
      }
      return false;
    }
    
    return false;
  }

  Future<bool> _requestAnyPermission({
    required List<Permission> permissions,
    required String permissionName,
  }) async {
    // Try each permission without showing multiple snackbars.
    for (final p in permissions) {
      final status = await p.request();
      if (status.isGranted || status.isLimited) return true;
      // If permanently denied, stop early and show settings dialog.
      if (status.isPermanentlyDenied) {
        if (mounted) _showPermissionDialog(permissionName);
        return false;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$permissionName permission is required'),
          backgroundColor: CricketSpiritColors.error,
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
    return false;
  }

  void _showPermissionDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionName Permission Required'),
        content: Text(
          'This app needs $permissionName permission to upload profile pictures. '
          'Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    try {
      // Request appropriate permission
      bool hasPermission = false;
      
      if (source == ImageSource.camera) {
        hasPermission = await _requestPermission(Permission.camera, 'Camera');
      } else {
        // Gallery:
        // - Android 13+: Permission.photos (READ_MEDIA_IMAGES)
        // - Older Android: Permission.storage
        // We request Photos first, then fall back to Storage, without showing
        // a confusing "Storage required" message on Android 13+ devices.
        hasPermission = await _requestAnyPermission(
          permissions: Platform.isAndroid
              ? <Permission>[Permission.photos, Permission.storage]
              : <Permission>[Permission.photos],
          permissionName: 'Photos',
        );
      }

      if (!hasPermission) return;

      final picker = ImagePicker();
      
      // Pick image
      XFile? pickedFile;
      try {
        pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1800,
          maxHeight: 1800,
          imageQuality: 85,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to access ${source == ImageSource.camera ? 'camera' : 'gallery'}.'),
              backgroundColor: CricketSpiritColors.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      if (pickedFile == null) return;

      // Crop the image
      try {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Profile Picture',
              toolbarColor: CricketSpiritColors.primary,
              toolbarWidgetColor: Colors.white,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
              ],
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Crop Profile Picture',
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
              ],
              aspectRatioLockEnabled: true,
            ),
          ],
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        );

        if (croppedFile != null) {
          setState(() {
            _profilePictureFile = File(croppedFile.path);
            // If user picked a new image while editing, force re-upload.
            _profilePictureUrl = null;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture selected successfully!'),
                backgroundColor: CricketSpiritColors.primary,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        // If cropping fails, use the original image
        setState(() {
          _profilePictureFile = File(pickedFile!.path);
          _profilePictureUrl = null;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image cropping skipped. Original image will be used.'),
              backgroundColor: CricketSpiritColors.primary,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process image: ${e.toString()}'),
            backgroundColor: CricketSpiritColors.error,
            duration: const Duration(seconds: 4),
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

  Future<void> _uploadProfilePicture() async {
    if (_profilePictureFile == null) return;

    try {
      final response = await apiService.uploadProfilePicture(_profilePictureFile!.path);
      setState(() {
        _profilePictureUrl = response['data']['fileUrl'];
      });
    } catch (e) {
      throw Exception('Failed to upload profile picture: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> _submitForm() async {
    setState(() => _submitted = true);
    
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: CricketSpiritColors.error,
        ),
      );
      return;
    }

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date of birth'),
          backgroundColor: CricketSpiritColors.error,
        ),
      );
      return;
    }

    // Only validate bowling types for bowlers and all-rounders
    if (_playerType != 'BATSMAN' && _selectedBowlingTypeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one bowling type'),
          backgroundColor: CricketSpiritColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload profile picture if selected
      if (_profilePictureFile != null && _profilePictureUrl == null) {
        await _uploadProfilePicture();
      }

      final payload = <String, dynamic>{
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'gender': _gender,
        'dateOfBirth': _dateOfBirth!.toIso8601String().split('T')[0],
        if (_profilePictureUrl != null) 'profilePicture': _profilePictureUrl,
        'playerType': _playerType,
        'isWicketKeeper': _isWicketKeeper,
        'batHand': _batHand,
        'bowlHand': _playerType == 'BATSMAN' ? null : _bowlHand,
        'bowlingTypeIds': _playerType == 'BATSMAN' ? [] : _selectedBowlingTypeIds,
        'address': {
          if (_streetController.text.trim().isNotEmpty)
            'street': _streetController.text.trim(),
          if (_townSuburbController.text.trim().isNotEmpty)
            'townSuburb': _townSuburbController.text.trim(),
          'city': (_selectedCity ?? _cityController.text).trim(),
          'state': (_selectedProvince ?? _stateController.text).trim(),
          'country': _countryController.text.trim().isEmpty
              ? 'Pakistan'
              : _countryController.text.trim(),
          if (_postalCodeController.text.trim().isNotEmpty)
            'postalCode': _postalCodeController.text.trim(),
        },
      };

      final Map<String, dynamic> response;
      if (_isEdit) {
        final id = widget.existingPlayer?.id;
        if (id == null || id.isEmpty) {
          throw Exception('Missing player id. Please refresh and try again.');
        }
        response = await apiService.updatePlayer(id: id, updates: payload);
      } else {
        response = await apiService.registerPlayer(
          firstName: payload['firstName'] as String,
          lastName: payload['lastName'] as String,
          gender: payload['gender'] as String,
          dateOfBirth: payload['dateOfBirth'] as String,
          profilePicture: payload['profilePicture'] as String?,
          playerType: payload['playerType'] as String,
          isWicketKeeper: payload['isWicketKeeper'] as bool,
          batHand: payload['batHand'] as String,
          bowlHand: payload['bowlHand'] as String?,
          bowlingTypeIds: (payload['bowlingTypeIds'] as List).cast<String>(),
          address: (payload['address'] as Map<String, dynamic>),
        );
      }

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Player profile created successfully!'),
            backgroundColor: CricketSpiritColors.primary,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
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
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Player Profile' : 'Register as Player'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode:
              _submitted ? AutovalidateMode.always : AutovalidateMode.disabled,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            children: [
              Text(
                _isEdit ? 'Update Your Player Profile' : 'Create Your Player Profile',
                style: textTheme.displaySmall,
              ),
              const SizedBox(height: 18),

              _sectionCard(
                title: 'Profile photo',
                child: _buildProfilePictureSection(),
              ),
              const SizedBox(height: 14),

              _sectionCard(
                title: 'Personal info',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _firstNameController,
                      enabled: !_isLoading,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.givenName],
                      decoration: const InputDecoration(
                        labelText: 'First name *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => _validateRequired(v, 'First name'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _lastNameController,
                      enabled: !_isLoading,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.familyName],
                      decoration: const InputDecoration(
                        labelText: 'Last name *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => _validateRequired(v, 'Last name'),
                    ),
                    const SizedBox(height: 14),

                    // Gender (segmented)
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'MALE', label: Text('Male')),
                          ButtonSegment(value: 'FEMALE', label: Text('Female')),
                        ],
                        selected: <String>{_gender},
                        onSelectionChanged: _isLoading
                            ? null
                            : (s) => setState(() => _gender = s.first),
                      ),
                    ),
                    const SizedBox(height: 14),

                    InkWell(
                      onTap: _isLoading ? null : _selectDateOfBirth,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date of birth *',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _dateOfBirth != null
                              ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                              : 'Select date',
                          style: TextStyle(
                            color: _dateOfBirth != null
                                ? CricketSpiritColors.foreground
                                : CricketSpiritColors.mutedForeground,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              _sectionCard(
                title: 'Player details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Player type', style: textTheme.titleMedium),
                    const SizedBox(height: 10),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'BATSMAN', label: Text('Batsman')),
                        ButtonSegment(value: 'BOWLER', label: Text('Bowler')),
                        ButtonSegment(
                          value: 'ALL_ROUNDER',
                          label: Text('All‑rounder'),
                        ),
                      ],
                      selected: <String>{_playerType},
                      onSelectionChanged: _isLoading
                          ? null
                          : (s) {
                              setState(() {
                                _playerType = s.first;
                                if (_playerType == 'BATSMAN') {
                                  _bowlHand = null;
                                  _selectedBowlingTypeIds.clear();
                                } else {
                                  _bowlHand ??= 'RIGHT';
                                }
                              });
                            },
                    ),
                    const SizedBox(height: 14),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: CricketSpiritColors.border),
                        borderRadius:
                            BorderRadius.circular(CricketSpiritRadius.input),
                      ),
                      child: SwitchListTile(
                        title: const Text('Wicket keeper'),
                        value: _isWicketKeeper,
                        onChanged: _isLoading
                            ? null
                            : (v) => setState(() => _isWicketKeeper = v),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text('Batting hand', style: textTheme.titleMedium),
                    const SizedBox(height: 10),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'LEFT', label: Text('Left')),
                        ButtonSegment(value: 'RIGHT', label: Text('Right')),
                      ],
                      selected: <String>{_batHand},
                      onSelectionChanged: _isLoading
                          ? null
                          : (s) => setState(() => _batHand = s.first),
                    ),
                  ],
                ),
              ),

              if (_playerType != 'BATSMAN') ...[
                const SizedBox(height: 14),
                _sectionCard(
                  title: 'Bowling',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bowling hand', style: textTheme.titleMedium),
                      const SizedBox(height: 10),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'LEFT', label: Text('Left')),
                          ButtonSegment(value: 'RIGHT', label: Text('Right')),
                        ],
                        selected: <String>{_bowlHand ?? 'RIGHT'},
                        onSelectionChanged: _isLoading
                            ? null
                            : (s) => setState(() => _bowlHand = s.first),
                      ),
                      const SizedBox(height: 14),
                      Text('Bowling types', style: textTheme.titleMedium),
                      const SizedBox(height: 10),
                      _buildBowlingTypesSection(),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              _sectionCard(
                title: 'Address',
                child: AutofillGroup(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _streetController,
                        enabled: !_isLoading,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        keyboardType: TextInputType.streetAddress,
                        autofillHints: const [AutofillHints.streetAddressLine1],
                        decoration: const InputDecoration(
                          labelText: 'Street address',
                          prefixIcon: Icon(Icons.home_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _townSuburbController,
                        enabled: !_isLoading,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        keyboardType: TextInputType.streetAddress,
                        autofillHints: const [AutofillHints.streetAddressLine2],
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
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: _isLoading || _isLoadingPakistanCities
                            ? null
                            : (v) {
                                setState(() {
                                  _selectedProvince = v;
                                  _stateController.text = v ?? '';
                                  // Clear city when province changes
                                  _selectedCity = null;
                                  _cityController.clear();
                                });
                              },
                        decoration: const InputDecoration(
                          labelText: 'Province / state *',
                          prefixIcon: Icon(Icons.map_outlined),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Province is required' : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _selectedCity,
                        isExpanded: true,
                        items: (_selectedProvince == null)
                            ? const []
                            : (_citiesByProvince[_selectedProvince] ?? [])
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                      c,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: _isLoading ||
                                _isLoadingPakistanCities ||
                                _selectedProvince == null
                            ? null
                            : (v) {
                                setState(() {
                                  _selectedCity = v;
                                  _cityController.text = v ?? '';
                                });
                              },
                        decoration: const InputDecoration(
                          labelText: 'City *',
                          prefixIcon: Icon(Icons.location_city),
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'City is required' : null,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _postalCodeController,
                              enabled: !_isLoading,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                              autofillHints: const [AutofillHints.postalCode],
                              decoration: const InputDecoration(
                                labelText: 'Postal code',
                                prefixIcon: Icon(Icons.markunread_mailbox),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextFormField(
                              controller: _countryController,
                              enabled: false,
                              decoration: const InputDecoration(
                                labelText: 'Country',
                                prefixIcon: Icon(Icons.public),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!_isLoadingPakistanCities && _provinces.isEmpty) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: _isLoading ? null : _loadPakistanCities,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              CricketSpiritColors.primaryForeground,
                            ),
                          ),
                        )
                      : Text(_isEdit ? 'Save changes' : 'Register player'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    final hasLocalPhoto = _profilePictureFile != null;
    final hasRemotePhoto =
        _profilePictureUrl != null && _profilePictureUrl!.trim().isNotEmpty;
    final hasPhoto = hasLocalPhoto || hasRemotePhoto;

    ImageProvider? image;
    if (hasLocalPhoto) {
      image = FileImage(_profilePictureFile!);
    } else if (hasRemotePhoto) {
      image = NetworkImage(_profilePictureUrl!);
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _isLoading ? null : _showImageSourceDialog,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: hasPhoto
                      ? CricketSpiritColors.primary.withOpacity(0.6)
                      : CricketSpiritColors.border,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                backgroundColor: CricketSpiritColors.secondary,
                backgroundImage:
                    image,
                child: image == null
                    ? const Icon(
                        Icons.add_a_photo_outlined,
                        color: CricketSpiritColors.mutedForeground,
                        size: 28,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _showImageSourceDialog,
                icon: Icon(hasPhoto ? Icons.edit_outlined : Icons.add),
                label: Text(hasPhoto ? 'Change' : 'Add'),
              ),
              if (hasPhoto)
                OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _profilePictureFile = null;
                            _profilePictureUrl = null;
                          });
                        },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CricketSpiritColors.error,
                    side: const BorderSide(color: CricketSpiritColors.error),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildBowlingTypesSection() {
    if (_isFetchingBowlingTypes) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          border: Border.all(color: CricketSpiritColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_bowlingTypes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: CricketSpiritColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: CricketSpiritColors.mutedForeground,
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load bowling types',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: CricketSpiritColors.mutedForeground,
                    ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _fetchBowlingTypes,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: CricketSpiritColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _bowlingTypes.map((type) {
          final isSelected = _selectedBowlingTypeIds.contains(type.id);
          return FilterChip(
            label: Text('${type.fullName} (${type.shortName})'),
            selected: isSelected,
            onSelected: _isLoading
                ? null
                : (selected) {
                    setState(() {
                      if (selected) {
                        _selectedBowlingTypeIds.add(type.id);
                      } else {
                        _selectedBowlingTypeIds.remove(type.id);
                      }
                    });
                  },
            selectedColor: CricketSpiritColors.primary.withOpacity(0.2),
            checkmarkColor: CricketSpiritColors.primary,
          );
        }).toList(),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initialDate = _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day);
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: CricketSpiritColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }
}
