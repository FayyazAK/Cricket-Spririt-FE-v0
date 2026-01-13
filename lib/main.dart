import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/app_state.dart';
import 'services/permissions/permission_service.dart';
import 'services/storage/storage_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  await storageService.init();

  // Initialize app state (load saved login status)
  await appState.initialize();

  // Request required permissions on startup
  await PermissionService.requestStartupPermissions();

  runApp(const CricketSpiritApp());
}


