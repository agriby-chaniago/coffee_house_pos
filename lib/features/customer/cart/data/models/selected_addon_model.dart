import 'package:freezed_annotation/freezed_annotation.dart';

part 'selected_addon_model.freezed.dart';
part 'selected_addon_model.g.dart';

@freezed
class SelectedAddOn with _$SelectedAddOn {
  const factory SelectedAddOn({
    required String addOnId,
    required String name,
    required String category,
    required double additionalPrice,
  }) = _SelectedAddOn;

  factory SelectedAddOn.fromJson(Map<String, dynamic> json) =>
      _$SelectedAddOnFromJson(json);
}
