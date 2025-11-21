import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String ordersBox = 'orders';
  static const String productsBox = 'products';
  static const String addonsBox = 'addons';
  static const String offlineQueueBox = 'offline_queue';
  static const String settingsBox = 'settings';
  static const String dailyCounterBox = 'daily_counter';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Open boxes (adapters will be registered later after build_runner)
    await Hive.openBox(ordersBox);
    await Hive.openBox(productsBox);
    await Hive.openBox(addonsBox);
    await Hive.openBox(offlineQueueBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox(dailyCounterBox);
  }

  static Box getOrdersBox() => Hive.box(ordersBox);
  static Box getProductsBox() => Hive.box(productsBox);
  static Box getAddonsBox() => Hive.box(addonsBox);
  static Box getOfflineQueueBox() => Hive.box(offlineQueueBox);
  static Box getSettingsBox() => Hive.box(settingsBox);
  static Box getDailyCounterBox() => Hive.box(dailyCounterBox);

  static Future<void> clearAllBoxes() async {
    await getOrdersBox().clear();
    await getProductsBox().clear();
    await getAddonsBox().clear();
    await getOfflineQueueBox().clear();
    await getSettingsBox().clear();
    await getDailyCounterBox().clear();
  }
}
