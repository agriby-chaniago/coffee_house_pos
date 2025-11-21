import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/constants/app_constants.dart';

part 'waste_log_model.freezed.dart';
part 'waste_log_model.g.dart';

@freezed
class WasteLog with _$WasteLog {
  const WasteLog._();

  const factory WasteLog({
    String? id,
    required String productId,
    required String productName,
    required double amount,
    required String stockUnit,
    required String reason, // Store as string for AppWrite
    String? notes,
    required String loggedBy,
    required DateTime timestamp,
  }) = _WasteLog;

  factory WasteLog.fromJson(Map<String, dynamic> json) =>
      _$WasteLogFromJson(json);
}

extension WasteLogExtension on WasteLog {
  WasteReason get reasonEnum {
    switch (reason.toLowerCase()) {
      case 'expired':
        return WasteReason.expired;
      case 'damaged':
        return WasteReason.damaged;
      case 'spilled':
        return WasteReason.spilled;
      case 'other':
        return WasteReason.other;
      default:
        return WasteReason.other;
    }
  }
}
