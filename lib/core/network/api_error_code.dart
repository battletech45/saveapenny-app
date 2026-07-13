enum ApiErrorCode {
  unknown('UNKNOWN_ERROR'),
  validationFailed('VALIDATION_FAILED'),
  invalidCredentials('INVALID_CREDENTIALS'),
  invalidPassword('INVALID_PASSWORD'),
  passwordReuseNotAllowed('PASSWORD_REUSE_NOT_ALLOWED'),
  invalidRefreshToken('INVALID_REFRESH_TOKEN'),
  refreshTokenExpired('REFRESH_TOKEN_EXPIRED'),
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
  recurringTransactionNotFound('RECURRING_TRANSACTION_NOT_FOUND'),
  recurringTransactionDependencyNotFound(
    'RECURRING_TRANSACTION_DEPENDENCY_NOT_FOUND',
  ),
  invalidRecurringTransactionNextRunDate(
    'INVALID_RECURRING_TRANSACTION_NEXT_RUN_DATE',
  ),
  invalidRecurringTransactionType('INVALID_RECURRING_TRANSACTION_TYPE'),
  invalidRecurringTransactionStatusTransition(
    'INVALID_RECURRING_TRANSACTION_STATUS_TRANSITION',
  ),
  goalNotFound('GOAL_NOT_FOUND'),
  scenarioNotFound('SCENARIO_NOT_FOUND'),
  linkedAccountNotFound('LINKED_ACCOUNT_NOT_FOUND'),
  insightNotFound('INSIGHT_NOT_FOUND'),
  insightGenerationFailed('INSIGHT_GENERATION_FAILED'),
  invalidGoalDate('INVALID_GOAL_DATE'),
  invalidGoalStatusTransition('INVALID_GOAL_STATUS_TRANSITION'),
  invalidGoalType('INVALID_GOAL_TYPE'),
  invalidGoalSimulationRequest('INVALID_GOAL_SIMULATION_REQUEST'),
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
  invalidStockSymbol('INVALID_STOCK_SYMBOL'),
  stockQuoteNotAvailable('STOCK_QUOTE_NOT_AVAILABLE'),
  stockHoldingNotFound('STOCK_HOLDING_NOT_FOUND'),
  duplicateStockHolding('DUPLICATE_STOCK_HOLDING'),
  stockRateLimitExceeded('STOCK_RATE_LIMIT_EXCEEDED'),
  stockProviderError('STOCK_PROVIDER_ERROR'),
  assistantDisabled('ASSISTANT_DISABLED'),
  stockDisabled('STOCK_DISABLED'),
  insightsDisabled('INSIGHTS_DISABLED'),
  goalProgressDisabled('GOAL_PROGRESS_DISABLED'),
  invalidImportFile('INVALID_IMPORT_FILE'),
  importNotFound('IMPORT_NOT_FOUND'),
  importAlreadyRunning('IMPORT_ALREADY_RUNNING'),
  featureDisabled('FEATURE_DISABLED'),
  serverError('SERVER_ERROR'),
  internalServerError('INTERNAL_SERVER_ERROR'),
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
        this == ApiErrorCode.refreshTokenExpired ||
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
