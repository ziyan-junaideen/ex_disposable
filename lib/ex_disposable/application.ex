defmodule ExDisposable.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_start_type, _start_arguments) do
    ExDisposable.Blocklist.ensure_loaded!()

    Supervisor.start_link([], strategy: :one_for_one, name: ExDisposable.Supervisor)
  end
end
