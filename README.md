# ExDisposable

Disposable email domain checks for Elixir applications, backed by the upstream
`disposable-email-domains` blocklist.

## Installation

Add `ex_disposable` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_disposable, "~> 0.3.0"}
  ]
end
```

`Ecto` support is optional. The core email checker works without it.

## Quick start

```elixir
iex> ExDisposable.disposable?("person@0-mail.com")
true

iex> ExDisposable.disposable?(" PERSON@subdomain.0-mail.com ")
true

iex> ExDisposable.disposable?("person@example.com")
false

iex> ExDisposable.disposable?("not-an-email")
false
```

`ExDisposable.disposable?/1` normalizes case and surrounding whitespace before
extracting the email domain. It also treats subdomains of blocked domains as
disposable.

## Ecto changeset validation

If your project uses `Ecto`, import `ExDisposable.Ecto.Changeset` and add the
validator to your changeset pipeline:

```elixir
def changeset(user, attrs) do
  user
  |> Ecto.Changeset.cast(attrs, [:email])
  |> Ecto.Changeset.validate_required([:email])
  |> ExDisposable.Ecto.Changeset.validate_not_disposable_email(:email)
end
```

The validator adds `"uses a disposable email domain"` by default. You can
override it with `message: "..."` when needed.

## Updating the bundled blocklist

Use `mix ex_disposable.sync_blocklist` to download the latest upstream disposable
email blocklist into `priv/disposable_email_blocklist.conf`. When the upstream
file changes, the task will:

1. sync `main` with `git pull --ff-only`
2. create a `blocklist-update-YYYY-MM-DD` branch from `main`
3. bump the patch version in `mix.exs`
4. commit the updated blocklist and version bump
5. push the branch and open a pull request with `gh`

The task prints each step as it runs and refuses to continue if the git worktree
is dirty.

## Generating docs locally

Install development dependencies and build the docs with:

```sh
mix deps.get
mix docs
```

## Development checks

Run the formatter, strict Credo checks, and test suite with:

```sh
mix format
mix credo --strict
mix test
```
