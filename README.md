# ExDisposable

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_disposable` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_disposable, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_disposable>.

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
