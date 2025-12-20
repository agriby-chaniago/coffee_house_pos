import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StoreInfo {
  final String name;
  final String address;
  final String phone;

  StoreInfo({
    required this.name,
    required this.address,
    required this.phone,
  });

  factory StoreInfo.fromMap(Map<String, dynamic> map) {
    return StoreInfo(
      name: map['name'] as String? ?? 'Coffee House',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
    };
  }

  StoreInfo copyWith({
    String? name,
    String? address,
    String? phone,
  }) {
    return StoreInfo(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }
}

class StoreInfoNotifier extends StateNotifier<StoreInfo> {
  late final Box _box;
  bool _isInitialized = false;

  StoreInfoNotifier()
      : super(StoreInfo(name: 'Coffee House', address: '', phone: '')) {
    _initBox();
  }

  Future<void> _initBox() async {
    try {
      _box = await Hive.openBox('settings');
      _isInitialized = true;
      await _loadStoreInfo();
    } catch (e) {
      print('❌ Error initializing settings box: $e');
      _isInitialized = false;
    }
  }

  Future<void> _loadStoreInfo() async {
    if (!_isInitialized) return;
    try {
      final storeInfoMap = _box.get('store_info');

      if (storeInfoMap != null) {
        state = StoreInfo.fromMap(Map<String, dynamic>.from(storeInfoMap));
      }
    } catch (e) {
      print('Error loading store info: $e');
    }
  }

  Future<void> updateStoreInfo({
    String? name,
    String? address,
    String? phone,
  }) async {
    if (!_isInitialized) return;
    try {
      state = state.copyWith(
        name: name,
        address: address,
        phone: phone,
      );

      await _box.put('store_info', state.toMap());

      print('✅ Store info saved: ${state.name}');
    } catch (e) {
      print('❌ Error saving store info: $e');
    }
  }
}

final storeInfoProvider =
    StateNotifierProvider<StoreInfoNotifier, StoreInfo>((ref) {
  return StoreInfoNotifier();
});
