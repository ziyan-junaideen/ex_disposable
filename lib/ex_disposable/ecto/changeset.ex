defmodule ExDisposable.Ecto.Changeset do
  @moduledoc """
  Helpers for validating email fields against disposable domains in
  `Ecto.Changeset`s.

  `ExDisposable.Ecto.Changeset` requires the optional `:ecto` dependency to be
  available at runtime.

  ## Examples

      iex> changeset =
      ...>   {%{}, %{email: :string}}
      ...>   |> Ecto.Changeset.cast(%{email: "person@0-mail.com"}, [:email])
      ...>   |> ExDisposable.Ecto.Changeset.validate_not_disposable_email(:email)
      iex> changeset.errors
      [email: {"uses a disposable email domain", []}]
  """

  @compile {:no_warn_undefined, Ecto.Changeset}

  @doc """
  Validates that the given email field does not use a disposable domain.

  ## Options

    * `:message` - overrides the default `"uses a disposable email domain"`
      validation message.

  ## Examples

      iex> changeset =
      ...>   {%{}, %{email: :string}}
      ...>   |> Ecto.Changeset.cast(%{email: "person@example.com"}, [:email])
      ...>   |> ExDisposable.Ecto.Changeset.validate_not_disposable_email(:email)
      iex> changeset.errors
      []

      iex> changeset =
      ...>   {%{}, %{email: :string}}
      ...>   |> Ecto.Changeset.cast(%{email: "person@0-mail.com"}, [:email])
      ...>   |> ExDisposable.Ecto.Changeset.validate_not_disposable_email(
      ...>     :email,
      ...>     message: "must not use a disposable inbox"
      ...>   )
      iex> changeset.errors
      [email: {"must not use a disposable inbox", []}]
  """
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
