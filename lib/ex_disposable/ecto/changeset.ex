defmodule ExDisposable.Ecto.Changeset do
  @moduledoc """
  Helpers for validating email fields against disposable domains in
  `Ecto.Changeset`s.

  ## Examples

      import ExDisposable.Ecto.Changeset

      changeset
      |> validate_not_disposable_email(:email)
  """

  @compile {:no_warn_undefined, Ecto.Changeset}

  @spec validate_not_disposable_email(term(), atom(), Keyword.t()) :: term()
  def validate_not_disposable_email(changeset, field, options \\ []) do
    ensure_ecto_changeset!()

    error_message = Keyword.get(options, :message, "uses a disposable email domain")

    Ecto.Changeset.validate_change(changeset, field, fn current_field, email_address ->
      if ExDisposable.disposable?(email_address) do
        [{current_field, error_message}]
      else
        []
      end
    end)
  end

  defp ensure_ecto_changeset! do
    if Code.ensure_loaded?(Ecto.Changeset) and
         function_exported?(Ecto.Changeset, :validate_change, 3) do
      :ok
    else
      raise ArgumentError,
            "ExDisposable.Ecto.Changeset requires the optional :ecto dependency to be available"
    end
  end
end
