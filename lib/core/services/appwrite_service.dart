import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/appwrite_config.dart';

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  late final Client _client;
  late final Account _account;
  late final Databases _databases;
  late final Storage _storage;
  late final Realtime _realtime;

  Client get client => _client;
  Account get account => _account;
  Databases get databases => _databases;
  Storage get storage => _storage;
  Realtime get realtime => _realtime;

  void initialize() {
    _client = Client()
        .setEndpoint(AppwriteConfig.endpoint)
        .setProject(AppwriteConfig.projectId);

    _account = Account(_client);
    _databases = Databases(_client);
    _storage = Storage(_client);
    _realtime = Realtime(_client);
  }

  // Helper method to get database ID
  String get databaseId => AppwriteConfig.databaseId;

  // Helper methods for collection IDs
  String get usersCollectionId => AppwriteConfig.usersCollection;
  String get productsCollectionId => AppwriteConfig.productsCollection;
  String get addonsCollectionId => AppwriteConfig.addonsCollection;
  String get ordersCollectionId => AppwriteConfig.ordersCollection;
  String get stockMovementsCollectionId =>
      AppwriteConfig.stockMovementsCollection;
  String get wasteLogsCollectionId => AppwriteConfig.wasteLogsCollection;

  // Helper method for storage bucket
  String get productImagesBucketId => AppwriteConfig.productImagesBucket;
}

// Riverpod provider for AppwriteService
final appwriteProvider = Provider<AppwriteService>((ref) {
  return AppwriteService();
});
