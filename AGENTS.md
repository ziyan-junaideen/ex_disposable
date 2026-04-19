# Agent Guidance for ExDisposable

## Scope

- This is a fresh Elixir library for identifying disposable email domains.
- The core data source is the upstream [disposable-email-domains](https://github.com/disposable-email-domains/disposable-email-domains) repository.
- Keep implementation focused on three areas: in-memory disposable-domain checks, a Mix task to sync and prepare releases from upstream data, and Ecto validation support.

## Working Rules

- Prefer small, composable modules over a single large API surface.
- Keep upstream sync and dataset preparation deterministic and testable.
- Treat generated or downloaded domain data as derived artifacts; do not hand-edit them.
- For Ecto integration, keep validators idiomatic and compatible with changesets.
- Add or update tests alongside behavior changes.
- Preserve the library style and conventions already established in [mix.exs](mix.exs), [lib/ex_disposable.ex](lib/ex_disposable.ex), and [test/ex_disposable_test.exs](test/ex_disposable_test.exs).

## Commands

- Format with `mix format`.
- Run tests with `mix test`.
- Compile with `mix compile`.

## Documentation

- Keep user-facing details in [README.md](README.md) instead of repeating them here.
- If future work adds implementation notes or release steps, link to them from this file rather than duplicating them.
