import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/themes/themes.dart';
import '../../services/api/api_service.dart';

class RegisterClubView extends StatefulWidget {
  const RegisterClubView({super.key});

  @override
  State<RegisterClubView> createState() => _RegisterClubViewState();
}

class _RegisterClubViewState extends State<RegisterClubView> {
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;
  bool _isLoading = false;
  bool _isLoadingPakistanCities = true;
  Map<String, List<String>> _citiesByProvince = {};
  List<String> _provinces = [];
  String? _selectedProvince;
  String? _selectedCity;

  // Controllers
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _streetController = TextEditingController();
  final _townSuburbController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // Form values
  DateTime? _establishedDate;
  String? _profilePictureUrl;
  File? _profilePictureFile;

  @override
  void initState() {
    super.initState();
    _loadPakistanCities();
    _countryController.text = 'Pakistan';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _streetController.dispose();
    _townSuburbController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
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
        final unique = list.toSet().toList()..sort();
        map[entry.key] = unique;
      }

      provinces.sort();

      if (!mounted) return;
      setState(() {
        _citiesByProvince = map;
        _provinces = provinces;
        _isLoadingPakistanCities = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingPakistanCities = false);
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
    for (final p in permissions) {
      final status = await p.request();
      if (status.isGranted || status.isLimited) return true;
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
          'This app needs $permissionName permission to upload club logo. '
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
      bool hasPermission = false;

      if (source == ImageSource.camera) {
        hasPermission = await _requestPermission(Permission.camera, 'Camera');
      } else {
        hasPermission = await _requestAnyPermission(
          permissions: Platform.isAndroid
              ? <Permission>[Permission.photos, Permission.storage]
              : <Permission>[Permission.photos],
          permissionName: 'Photos',
        );
      }

      if (!hasPermission) return;

      final picker = ImagePicker();

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

      try {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Club Logo',
              toolbarColor: CricketSpiritColors.primary,
              toolbarWidgetColor: Colors.white,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
              ],
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Crop Club Logo',
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
            _profilePictureUrl = null;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Club logo selected successfully!'),
                backgroundColor: CricketSpiritColors.primary,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
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

  Future<void> _uploadClubLogo() async {
    if (_profilePictureFile == null) return;

    try {
      final response = await apiService.uploadClubProfilePicture(_profilePictureFile!.path);
      setState(() {
        _profilePictureUrl = response['data']['filePath'];
      });
    } catch (e) {
      throw Exception('Failed to upload club logo: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> _selectEstablishedDate() async {
    final now = DateTime.now();
    final initialDate = _establishedDate ?? DateTime(now.year - 1, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select established date',
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

    setState(() => _isLoading = true);

    try {
      // Upload club logo if selected
      if (_profilePictureFile != null && _profilePictureUrl == null) {
        await _uploadClubLogo();
      }

      final response = await apiService.createClub(
        name: _nameController.text.trim(),
        profilePicture: _profilePictureUrl,
        bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
        establishedDate: _establishedDate?.toIso8601String().split('T')[0],
        address: {
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
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Club created successfully!'),
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
        title: const Text('Create Club'),
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
                'Create Your Club',
                style: textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Set up your cricket club and start building your team',
                style: textTheme.bodyMedium?.copyWith(
                  color: CricketSpiritColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 24),

              _sectionCard(
                title: 'Club Logo',
                child: _buildLogoSection(),
              ),
              const SizedBox(height: 14),

              _sectionCard(
                title: 'Club Details',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      enabled: !_isLoading,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Club name *',
                        prefixIcon: Icon(Icons.business_outlined),
                        hintText: 'e.g. Karachi Kings Cricket Club',
                      ),
                      validator: (v) => _validateRequired(v, 'Club name'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _bioController,
                      enabled: !_isLoading,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                      maxLines: 3,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'About the club',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 48),
                          child: Icon(Icons.description_outlined),
                        ),
                        hintText: 'Tell us about your club...',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _isLoading ? null : _selectEstablishedDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Established date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _establishedDate != null
                              ? '${_establishedDate!.day}/${_establishedDate!.month}/${_establishedDate!.year}'
                              : 'Select date (optional)',
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
              const SizedBox(height: 14),

              _sectionCard(
                title: 'Club Address',
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

              const SizedBox(height: 24),

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
                      : const Text('Create Club'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
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
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasPhoto
                      ? CricketSpiritColors.primary.withOpacity(0.6)
                      : CricketSpiritColors.border,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: image != null
                    ? Image(
                        image: image,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      )
                    : Container(
                        color: CricketSpiritColors.secondary,
                        child: const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: CricketSpiritColors.mutedForeground,
                          size: 40,
                        ),
                      ),
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
                label: Text(hasPhoto ? 'Change' : 'Add Logo'),
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
}
