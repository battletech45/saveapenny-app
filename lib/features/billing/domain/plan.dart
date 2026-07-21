enum Plan {
  free('free'),
  plus('plus');

  const Plan(this.wireValue);

  final String wireValue;

  static Plan fromWire(String? wireValue) {
    return Plan.values.firstWhere(
      (value) => value.wireValue == wireValue,
      orElse: () => Plan.free,
    );
  }
}

enum EntitlementStatus {
  inactive('inactive'),
  trialing('trialing'),
  active('active'),
  gracePeriod('grace_period'),
  canceled('canceled'),
  expired('expired');

  const EntitlementStatus(this.wireValue);

  final String wireValue;

  static EntitlementStatus fromWire(String? wireValue) {
    return EntitlementStatus.values.firstWhere(
      (value) => value.wireValue == wireValue,
      orElse: () => EntitlementStatus.inactive,
    );
  }
}
