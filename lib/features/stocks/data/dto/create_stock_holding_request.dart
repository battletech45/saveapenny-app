import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_stock_holding_request.freezed.dart';
part 'create_stock_holding_request.g.dart';

@freezed
abstract class CreateStockHoldingRequest with _$CreateStockHoldingRequest {
  const factory CreateStockHoldingRequest({
    required String symbol,
    required String quantity,
    required String purchasePrice,
    required String currency,
    required String purchaseDate,
    String? notes,
  }) = _CreateStockHoldingRequest;

  factory CreateStockHoldingRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateStockHoldingRequestFromJson(json);
}
