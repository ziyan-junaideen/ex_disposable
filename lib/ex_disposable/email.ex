defmodule ExDisposable.Email do
  @moduledoc false

  @spec domain(term()) :: String.t() | nil
  def domain(email_address) when is_binary(email_address) do
    normalized_email_address =
      email_address
      |> String.trim()
      |> String.downcase()

    cond do
      normalized_email_address == "" ->
        nil

      String.match?(normalized_email_address, ~r/\s/u) ->
        nil

      true ->
        extract_domain(normalized_email_address)
    end
  end

  def domain(_other), do: nil

  @spec normalize_domain(term()) :: String.t() | nil
  def normalize_domain(domain) when is_binary(domain) do
    normalized_domain =
      domain
      |> String.trim()
      |> String.downcase()

    cond do
      normalized_domain == "" ->
        nil

      String.match?(normalized_domain, ~r/\s/u) ->
        nil

      true ->
        validate_domain_labels(normalized_domain)
    end
  end

  def normalize_domain(_other), do: nil

  defp extract_domain(normalized_email_address) do
    case String.split(normalized_email_address, "@") do
      [local_part, domain] when local_part != "" ->
        normalize_domain(domain)

      _other ->
        nil
    end
  end

  defp validate_domain_labels(normalized_domain) do
    domain_labels = String.split(normalized_domain, ".", trim: false)

    if Enum.all?(domain_labels, &(&1 != "")) do
      normalized_domain
    else
      nil
    end
  end
end
