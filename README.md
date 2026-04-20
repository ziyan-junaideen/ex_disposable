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

## Usage

```elixir
iex> ExDisposable.disposable?("person@0-mail.com")
true

iex> ExDisposable.disposable?("person@example.com")
false
```

The check normalizes case and surrounding whitespace before extracting the email
domain.

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

You can override the default error message with `message: "..."`
when needed.

## Development

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
