defmodule ExDisposable do
  @moduledoc """
  Checks whether an email address belongs to a disposable email domain.
  """

  @doc """
  Returns `true` when the email address uses a disposable email domain from the
  bundled blocklist.

  Invalid or incomplete email addresses return `false`.

  ## Examples

      iex> ExDisposable.disposable?("person@0-mail.com")
      true

      iex> ExDisposable.disposable?("person@example.com")
      false

      iex> ExDisposable.disposable?("not-an-email")
      false

  """
  @spec disposable?(term()) :: boolean()
  def disposable?(email_address) when is_binary(email_address) do
    case ExDisposable.Email.domain(email_address) do
      nil ->
        false

      domain ->
        ExDisposable.Blocklist.disposable_domain?(domain)
    end
  end

  def disposable?(_other), do: false
end
