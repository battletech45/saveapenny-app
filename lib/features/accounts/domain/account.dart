import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';

enum AccountType { cash, bank, credit, savings, investment }

@freezed
abstract class Account with _$Account {
  const factory Account({
    required String id,
    required String name,
    required AccountType type,
    required String currency,
    required num balance,
    required num initialBalance,
    required bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Account;
}
