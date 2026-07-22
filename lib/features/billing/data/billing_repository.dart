import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/billing/data/billing_api.dart';
import 'package:saveapenny/features/billing/data/dto/entitlement_response.dart';
import 'package:saveapenny/features/billing/domain/billing_repository.dart';
import 'package:saveapenny/features/billing/domain/entitlement.dart';

part 'billing_repository.g.dart';

class BillingRepositoryImpl implements BillingRepository {
  const BillingRepositoryImpl(this._billingApi);

  final BillingApi _billingApi;

  @override
  Future<Entitlement> getEntitlement() async {
    final response = await _billingApi.getEntitlement();
    return response.toDomain();
  }

  @override
  Future<Entitlement> sync() async {
    final response = await _billingApi.sync();
    return response.toDomain();
  }
}

@Riverpod(keepAlive: true)
BillingRepository billingRepository(Ref ref) {
  return BillingRepositoryImpl(ref.watch(billingApiProvider));
}
