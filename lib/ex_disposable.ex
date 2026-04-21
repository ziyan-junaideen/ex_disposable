defmodule ExDisposable do
  @moduledoc """
  Public API for checking whether an email address belongs to a disposable email
  domain.

  `ExDisposable` ships with a bundled copy of the upstream
  `disposable-email-domains` blocklist and performs fast in-memory checks at
  runtime.

  For Ecto changeset validation, see `ExDisposable.Ecto.Changeset`.

  ## Examples

      iex> ExDisposable.disposable?("person@0-mail.com")
      true

      iex> ExDisposable.disposable?(" PERSON@subdomain.0-mail.com ")
      true

      iex> ExDisposable.disposable?("person@example.com")
      false
  """

  @doc """
  Returns `true` when the email address uses a disposable email domain from the
  bundled blocklist.

  The check normalizes case and surrounding whitespace before extracting the
  domain. Invalid or incomplete email addresses return `false`.

  ## Examples

      iex> ExDisposable.disposable?("person@0-mail.com")
      true

      iex> ExDisposable.disposable?(" PERSON@0-MAIL.COM ")
      true

      iex> ExDisposable.disposable?("person@subdomain.0-mail.com")
      true

      iex> ExDisposable.disposable?("person@example.com")
      false

      iex> ExDisposable.disposable?("not-an-email")
      false

      iex> ExDisposable.disposable?(nil)
      false

  """
  @spec disposable?(term()) :: boolean()
  def disposable?(email_address) when is_binary(email_address) do
    case ExDisposable.Email.domain(email_address) do
      nil ->
        false

      normalized_domain ->
        ExDisposable.Blocklist.disposable_normalized_domain?(normalized_domain)
    end
  end

  def disposable?(_other), do: false
end
