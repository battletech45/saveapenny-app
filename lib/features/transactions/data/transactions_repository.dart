import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/storage/cached_fetch.dart';
import 'package:saveapenny/core/storage/response_cache_store.dart';
import 'package:saveapenny/features/transactions/data/dto/create_transaction_request.dart';
import 'package:saveapenny/features/transactions/data/dto/create_transfer_request.dart';
import 'package:saveapenny/features/transactions/data/dto/transaction_response.dart';
import 'package:saveapenny/features/transactions/data/dto/update_transaction_request.dart';
import 'package:saveapenny/features/transactions/data/transactions_api.dart';
import 'package:saveapenny/features/transactions/domain/transaction.dart';
import 'package:saveapenny/features/transactions/domain/transactions_repository.dart';

part 'transactions_repository.g.dart';

const String _recentListCachePrefix = 'transactions:list:recent:';

class TransactionsRepositoryImpl implements TransactionsRepository {
  const TransactionsRepositoryImpl(this._transactionsApi, this._cache);

  final TransactionsApi _transactionsApi;
  final ResponseCacheStore _cache;

  @override
  Future<PaginatedData<Transaction>> list({
    DateTime? from,
    DateTime? to,
    TransactionType? type,
    String? accountId,
    String? categoryId,
    num? minAmount,
    num? maxAmount,
    String? keyword,
    int page = 0,
    int size = 20,
    String sort = 'transactionDate,desc',
  }) async {
    // Only the default, unfiltered "recent activity" view (no filters, first
    // page) is cached — see docs/adr/0003-offline-read-cache.md Phase 3.
    // Filtered/searched lists and load-more pages call straight through
    // with no fallback, so a stale filtered result is never shown as if
    // it matched the current filters.
    final isDefaultView =
        page == 0 &&
        from == null &&
        to == null &&
        type == null &&
        accountId == null &&
        categoryId == null &&
        minAmount == null &&
        maxAmount == null &&
        (keyword == null || keyword.isEmpty);

    if (!isDefaultView) {
      final response = await _transactionsApi.list(
        from: from,
        to: to,
        type: type == null ? null : _transactionTypeToWire(type),
        accountId: accountId,
        categoryId: categoryId,
        minAmount: minAmount,
        maxAmount: maxAmount,
        keyword: keyword,
        page: page,
        size: size,
        sort: sort,
      );
      return _toDomainPage(response);
    }

    final response = await cachedFetch<PaginatedData<TransactionResponse>>(
      cache: _cache,
      key: '$_recentListCachePrefix$size:$sort',
      call: () => _transactionsApi.list(page: page, size: size, sort: sort),
      toJson: (page) => <String, dynamic>{
        'items': page.items.map((item) => item.toJson()).toList(),
        'page': page.page,
        'size': page.size,
        'totalItems': page.totalItems,
        'totalPages': page.totalPages,
        'hasNext': page.hasNext,
        'hasPrevious': page.hasPrevious,
      },
      fromJson: (json) => PaginatedData<TransactionResponse>.fromJson(
        json,
        (item) => TransactionResponse.fromJson(item! as Map<String, dynamic>),
      ),
    );
    return _toDomainPage(response);
  }

  PaginatedData<Transaction> _toDomainPage(
    PaginatedData<TransactionResponse> response,
  ) {
    return PaginatedData<Transaction>(
      items: response.items
          .map((TransactionResponse item) => item.toDomain())
          .toList(growable: false),
      page: response.page,
      size: response.size,
      totalItems: response.totalItems,
      totalPages: response.totalPages,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
    );
  }

  @override
  Future<Transaction> create({
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  }) async {
    final response = await _transactionsApi.create(
      CreateTransactionRequest(
        accountId: accountId,
        categoryId: categoryId,
        type: _transactionTypeToWire(type),
        amount: amount,
        currency: currency,
        description: _normalizeDescription(description),
        transactionDate: _toWireDate(transactionDate),
      ),
    );
    await _cache.invalidatePrefix(_recentListCachePrefix);

    return response.toDomain();
  }

  @override
  Future<Transaction> update({
    required String transactionId,
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  }) async {
    final response = await _transactionsApi.update(
      transactionId: transactionId,
      request: UpdateTransactionRequest(
        accountId: accountId,
        categoryId: categoryId,
        type: _transactionTypeToWire(type),
        amount: amount,
        currency: currency,
        description: _normalizeDescription(description),
        transactionDate: _toWireDate(transactionDate),
      ),
    );
    await _cache.invalidatePrefix(_recentListCachePrefix);

    return response.toDomain();
  }

  @override
  Future<void> createTransfer({
    required String fromAccountId,
    required String toAccountId,
    required String categoryId,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  }) async {
    await _transactionsApi.createTransfer(
      CreateTransferRequest(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        categoryId: categoryId,
        amount: amount,
        currency: currency,
        description: _normalizeDescription(description),
        transactionDate: _toWireDate(transactionDate),
      ),
    );
    await _cache.invalidatePrefix(_recentListCachePrefix);
  }

  @override
  Future<void> delete(String transactionId) async {
    await _transactionsApi.delete(transactionId);
    await _cache.invalidatePrefix(_recentListCachePrefix);
  }
}

String _transactionTypeToWire(TransactionType type) {
  return switch (type) {
    TransactionType.income => 'INCOME',
    TransactionType.expense => 'EXPENSE',
    TransactionType.transfer => 'TRANSFER',
  };
}

String _toWireDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String? _normalizeDescription(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

@Riverpod(keepAlive: true)
TransactionsRepository transactionsRepository(Ref ref) {
  return TransactionsRepositoryImpl(
    ref.watch(transactionsApiProvider),
    ref.watch(responseCacheStoreProvider),
  );
}
