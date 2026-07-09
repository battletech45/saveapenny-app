import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_stock_holding_request.freezed.dart';
part 'update_stock_holding_request.g.dart';

@freezed
abstract class UpdateStockHoldingRequest with _$UpdateStockHoldingRequest {
  const factory UpdateStockHoldingRequest({
    String? quantity,
    String? purchasePrice,
    String? currency,
    String? purchaseDate,
    String? notes,
  }) = _UpdateStockHoldingRequest;

  factory UpdateStockHoldingRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateStockHoldingRequestFromJson(json);
}
