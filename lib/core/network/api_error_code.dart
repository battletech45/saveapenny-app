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
  budgetNotFound('BUDGET_NOT_FOUND'),
  budgetAlreadyExists('BUDGET_ALREADY_EXISTS'),
  invalidBudgetDateRange('INVALID_BUDGET_DATE_RANGE'),
  transactionNotFound('TRANSACTION_NOT_FOUND'),
  invalidTransactionCurrency('INVALID_TRANSACTION_CURRENCY'),
  invalidTransfer('INVALID_TRANSFER'),
  insufficientBalance('INSUFFICIENT_BALANCE'),
  accountMutationNotAllowed('ACCOUNT_MUTATION_NOT_ALLOWED'),
  accountInactive('ACCOUNT_INACTIVE'),
  conflict('CONFLICT'),
  emailAlreadyExists('EMAIL_ALREADY_EXISTS'),
  accessDenied('ACCESS_DENIED'),
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
        this == ApiErrorCode.unauthorized ||
        this == ApiErrorCode.accessDenied;
  }

  bool get isFeatureDisabled {
    return this == ApiErrorCode.assistantDisabled ||
        this == ApiErrorCode.stockDisabled ||
        this == ApiErrorCode.insightsDisabled ||
        this == ApiErrorCode.goalProgressDisabled ||
        this == ApiErrorCode.featureDisabled;
  }
}
