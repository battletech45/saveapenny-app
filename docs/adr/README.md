# Architecture Decision Records

Short, immutable records of the few decisions that (a) had a real alternative we
rejected and (b) an AI agent might "helpfully" reverse. Most rationale lives in
`CLAUDE.md` / `ARCHITECTURE.md` / `DESIGN_SYSTEM.md`; only decisions that need a
reversal-resistant guard get a file here.

## Rules

- Append-only. Don't rewrite an accepted record; supersede it with a new one and
  mark the old `Superseded by NNNN`.
- An `Accepted` ADR is binding — code and AI agents must not contradict it.
- To add one, copy `template.md`, increment the number, keep it to one screen.
  Bar for adding: non-obvious + real rejected alternative + costly/AI-reversible.

## Index

| # | Title | Status |
|---|-------|--------|
| [0001](0001-repositories-throw-failures.md) | Repositories throw `Failure` into `AsyncValue` | Accepted |
| [0002](0002-handwritten-api-envelope.md) | Hand-written generic `ApiEnvelope` | Accepted |