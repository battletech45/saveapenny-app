# API Contract — SaveAPenny Backend

Client-facing summary of the backend contract, derived from the backend's own
docs. The OpenAPI spec at `GET {baseUrl}/v3/api-docs` is the ultimate source of
truth for field-level schemas — generate/verify DTOs against it.

## Base & conventions

| Thing | Value |
|---|---|
| Base URL | `{host}/api/v1` |
| IDs | UUID v4 (string) |
| Dates | ISO-8601 (`2026-06-09`) |
| Date-times | ISO-8601 + tz (`2026-06-09T12:00:00Z`) |
| Currency | ISO-4217 (`USD`, `EUR`, `TRY`) |
| Pagination request | `page` (0-based), `size`, `sort` |
| Auth header | `Authorization: Bearer <accessToken>` |

## Envelope

Success:
```json
{ "success": true, "data": { }, "error": null, "timestamp": "2026-06-09T12:00:00Z" }
```
Error:
```json
{ "success": false, "data": null,
  "error": { "code": "VALIDATION_FAILED", "message": "...", "details": [] },
  "timestamp": "2026-06-09T12:00:00Z" }
```
Parse everything through `ApiEnvelope<T>`. `VALIDATION_FAILED` puts field messages
in `details` (e.g. `"amount: must not be null"`).

## Paginated payload

```json
{ "items": [ ], "page": 0, "size": 20, "totalItems": 125,
  "totalPages": 7, "hasNext": true, "hasPrevious": false }
```
`items` is always an array, never null. Ignore framework fields like `content`,
`pageable`, `sort`, `first`, `last` — they're not part of the contract.

## Auth flow (dual token)

| Token | Format | Expiry | Notes |
|---|---|---|---|
| Access | JWT HS512 | 15 min | stateless, not revocable |
| Refresh | opaque Base64URL | 7 days | stored server-side, **rotated every use** |

Endpoints (all public, all POST except where noted):

| Method | Path | Description |
|---|---|---|
| POST | `/api/v1/auth/register` | create account → token pair |
| POST | `/api/v1/auth/login` | authenticate → token pair (rate-limited 5/min/IP) |
| POST | `/api/v1/auth/refresh` | rotate → new token pair |
| POST | `/api/v1/auth/logout` | revoke refresh token |

Token-pair response `data`:
```json
{ "accessToken": "<jwt>", "refreshToken": "<opaque>",
  "expiresIn": 900, "tokenType": "Bearer" }
```

### Client refresh strategy (implement in `auth_interceptor.dart`)

Proactive (preferred):
1. Before each call, decode JWT `exp`.
2. If expired or `< 60s` remaining → `POST /auth/refresh` with current refresh
   token, store the new pair, then proceed.
3. If refresh returns 401 → clear tokens → route to `/login`.

Reactive fallback: on a `401`, attempt one refresh + retry; if that 401s too,
clear tokens and redirect.

Token-reuse detection: because refresh tokens rotate, a stale refresh token
returns `401 INVALID_REFRESH_TOKEN` → treat as session end.

Password change (`PUT /api/v1/users/me/password`) revokes **all** refresh tokens;
the current access token still works until it expires (≤15 min).

## Storage

| Platform | Mechanism (provided by flutter_secure_storage) |
|---|---|
| iOS | Keychain (`kSecClassGenericPassword`) |
| Android | EncryptedSharedPreferences |

Never store tokens in plaintext / SharedPreferences / UserDefaults.

## Rate limiting

`429 RATE_LIMITED` (or `STOCK_RATE_LIMIT_EXCEEDED`) includes `Retry-After:
<seconds>`. Wait at least that long before retrying. Surface a friendly message;
don't hammer.

## Error codes

Mirrored 1:1 in `lib/core/network/api_error_code.dart`. Grouped by HTTP class:
401 auth, 403 forbidden, 400 validation, 404 not-found, 409 conflict, 429
rate-limit, 503 feature-disabled, 5xx server. Map each to localized user copy in
the l10n layer — don't show raw server `message` strings as primary UI text.

## Feature flags (server-side)

Some features can be disabled on the server and will return 503:
- `ASSISTANT_DISABLED` — AI assistant ("Penny Dog") off
- `STOCK_DISABLED` — stock endpoints off / no Alpha Vantage key

The client must handle these gracefully (hide/disable the feature, not crash).

## Endpoint families (build DTOs per feature from OpenAPI)

auth · users · accounts · categories · transactions (+ transfers) · budgets ·
recurring transactions · reports (monthly summary, net worth) · imports (CSV
preview/confirm) · ocr (receipt jobs) · notifications · audit logs · insights ·
goals (+ scenarios, simulation, what-if) · stocks · assistant.

> Admin: `GET /admin/metrics` returns a raw map, **not** the envelope. Don't parse
> it through `ApiEnvelope`. (Unlikely to be used by the mobile client.)