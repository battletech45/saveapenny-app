import 'package:saveapenny/features/billing/domain/entitlement.dart';

abstract interface class BillingRepository {
  Future<Entitlement> getEntitlement();

  Future<Entitlement> sync();
}
