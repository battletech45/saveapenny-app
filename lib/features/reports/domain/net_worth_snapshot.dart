import 'package:freezed_annotation/freezed_annotation.dart';

part 'net_worth_snapshot.freezed.dart';

@freezed
abstract class NetWorthSnapshot with _$NetWorthSnapshot {
  const factory NetWorthSnapshot({
    required DateTime snapshotDate,
    required num totalAssets,
    required num totalLiabilities,
    required num netWorth,
  }) = _NetWorthSnapshot;
}
