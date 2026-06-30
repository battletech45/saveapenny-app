enum ApiErrorCode {
  unknown('UNKNOWN_ERROR'),
  validationFailed('VALIDATION_FAILED'),
  invalidCredentials('INVALID_CREDENTIALS'),
  invalidPassword('INVALID_PASSWORD'),
  invalidRefreshToken('INVALID_REFRESH_TOKEN'),
  accessTokenExpired('ACCESS_TOKEN_EXPIRED'),
  unauthorized('UNAUTHORIZED'),
  forbidden('FORBIDDEN'),
  resourceNotFound('RESOURCE_NOT_FOUND'),
  userNotFound('USER_NOT_FOUND'),
  accountNotFound('ACCOUNT_NOT_FOUND'),
  categoryNotFound('CATEGORY_NOT_FOUND'),
  transactionNotFound('TRANSACTION_NOT_FOUND'),
  conflict('CONFLICT'),
  emailAlreadyExists('EMAIL_ALREADY_EXISTS'),
  rateLimited('RATE_LIMITED'),
  stockRateLimitExceeded('STOCK_RATE_LIMIT_EXCEEDED'),
  assistantDisabled('ASSISTANT_DISABLED'),
  stockDisabled('STOCK_DISABLED'),
  insightsDisabled('INSIGHTS_DISABLED'),
  goalProgressDisabled('GOAL_PROGRESS_DISABLED'),
  featureDisabled('FEATURE_DISABLED'),
  serverError('SERVER_ERROR'),
  serviceUnavailable('SERVICE_UNAVAILABLE');

  const ApiErrorCode(this.wireValue);

  final String wireValue;

  static ApiErrorCode fromWire(String? wireValue) {
    if (wireValue == null || wireValue.isEmpty) {
      return ApiErrorCode.unknown;
    }

    for (final value in ApiErrorCode.values) {
      if (value.wireValue == wireValue) {
        return value;
      }
    }

    return ApiErrorCode.unknown;
  }

  bool get isAuthExpiry {
    return this == ApiErrorCode.accessTokenExpired ||
        this == ApiErrorCode.invalidRefreshToken ||
        this == ApiErrorCode.unauthorized;
  }

  bool get isFeatureDisabled {
    return this == ApiErrorCode.assistantDisabled ||
        this == ApiErrorCode.stockDisabled ||
        this == ApiErrorCode.insightsDisabled ||
        this == ApiErrorCode.goalProgressDisabled ||
        this == ApiErrorCode.featureDisabled;
  }
}
