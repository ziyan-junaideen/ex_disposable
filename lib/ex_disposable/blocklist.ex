defmodule ExDisposable.Blocklist do
  @moduledoc false

  @compile_time_blocklist_path Path.expand("../../priv/disposable_email_blocklist.conf", __DIR__)
  @domains_persistent_term_key {__MODULE__, :domains}
  @external_resource @compile_time_blocklist_path

  @spec disposable_domain?(term()) :: boolean()
  def disposable_domain?(domain) do
    case ExDisposable.Email.normalize_domain(domain) do
      nil ->
        false

      normalized_domain ->
        disposable_normalized_domain?(normalized_domain)
    end
  end

  @spec disposable_normalized_domain?(String.t()) :: boolean()
  def disposable_normalized_domain?(normalized_domain) when is_binary(normalized_domain) do
    disposable_domain_suffix?(domains(), normalized_domain)
  end

  @spec ensure_loaded!() :: :ok
  def ensure_loaded! do
    domains()
    :ok
  end

  defp domains do
    case :persistent_term.get(@domains_persistent_term_key, :persistent_term_missing) do
      :persistent_term_missing ->
        loaded_domains = load_domains!()
        :persistent_term.put(@domains_persistent_term_key, loaded_domains)
        loaded_domains

      loaded_domains ->
        loaded_domains
    end
  end

  defp load_domains! do
    blocklist_path()
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == "" or String.starts_with?(&1, "#")))
    |> MapSet.new()
  end

  defp blocklist_path do
    Application.app_dir(:ex_disposable, "priv/disposable_email_blocklist.conf")
  end

  defp disposable_domain_suffix?(domains, current_domain) do
    if MapSet.member?(domains, current_domain) do
      true
    else
      case :binary.match(current_domain, ".") do
        :nomatch ->
          false

        {separator_index, 1} ->
          remaining_domain_size = byte_size(current_domain) - separator_index - 1
          next_domain = binary_part(current_domain, separator_index + 1, remaining_domain_size)
          disposable_domain_suffix?(domains, next_domain)
      end
    end
  end
end
