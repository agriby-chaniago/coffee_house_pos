class AppwriteConfig {
  // TODO: Replace with your AppWrite endpoint and project ID
  // static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String endpoint = 'https://sgp.cloud.appwrite.io/v1';
  static const String projectId =
      '69207202000e114aa29f'; // Replace with your project ID

  // Database
  static const String databaseId = '69207635002a0ec7f15d';

  // Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String addonsCollection = 'addons';
  static const String ordersCollection = 'orders';
  static const String stockMovementsCollection = 'stock_movements';
  static const String wasteLogsCollection = 'waste_logs';

  // Storage
  static const String productImagesBucket = 'product-images';

  // OAuth
  // For Android, use appwrite-callback-[PROJECT_ID] format
  static const String successUrl =
      'appwrite-callback-$projectId://oauth2callback';
  static const String failureUrl =
      'appwrite-callback-$projectId://oauth2callback';
}
