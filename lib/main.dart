import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/hive_service.dart';
import 'core/services/offline_sync_manager.dart';
import 'core/services/appwrite_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for offline storage
  await HiveService.init();

  runApp(
    const ProviderScope(
      child: CoffeeHouseApp(),
    ),
  );
}

class CoffeeHouseApp extends ConsumerStatefulWidget {
  const CoffeeHouseApp({super.key});

  @override
  ConsumerState<CoffeeHouseApp> createState() => _CoffeeHouseAppState();
}

class _CoffeeHouseAppState extends ConsumerState<CoffeeHouseApp> {
  @override
  void initState() {
    super.initState();

    // Initialize offline sync manager after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSyncManager();
    });
  }

  Future<void> _initializeSyncManager() async {
    try {
      final appwrite = ref.read(appwriteProvider);
      await OfflineSyncManager().initialize(appwrite.databases);
      print('✅ Sync manager initialized from main.dart');
    } catch (e) {
      print('⚠️ Failed to initialize sync manager: $e');
    }
  }

  @override
  void dispose() {
    OfflineSyncManager().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Coffee House POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
