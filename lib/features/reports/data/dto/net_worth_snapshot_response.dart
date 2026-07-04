import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/reports/domain/net_worth_snapshot.dart';

part 'net_worth_snapshot_response.freezed.dart';
part 'net_worth_snapshot_response.g.dart';

@freezed
abstract class NetWorthSnapshotResponse with _$NetWorthSnapshotResponse {
  const factory NetWorthSnapshotResponse({
    required DateTime snapshotDate,
    required num totalAssets,
    required num totalLiabilities,
    required num netWorth,
  }) = _NetWorthSnapshotResponse;

  factory NetWorthSnapshotResponse.fromJson(Map<String, dynamic> json) =>
      _$NetWorthSnapshotResponseFromJson(json);
}

extension NetWorthSnapshotResponseX on NetWorthSnapshotResponse {
  NetWorthSnapshot toDomain() {
    return NetWorthSnapshot(
      snapshotDate: snapshotDate,
      totalAssets: totalAssets,
      totalLiabilities: totalLiabilities,
      netWorth: netWorth,
    );
  }
}
