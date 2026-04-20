defmodule ExDisposable.Blocklist do
  @moduledoc false

  @blocklist_path Path.expand("../../priv/disposable_email_blocklist.conf", __DIR__)
  @external_resource @blocklist_path

  @domains @blocklist_path
           |> File.read!()
           |> String.split("\n", trim: true)
           |> Enum.map(&String.trim/1)
           |> Enum.reject(&(&1 == "" or String.starts_with?(&1, "#")))
           |> MapSet.new()

  @spec disposable_domain?(term()) :: boolean()
  def disposable_domain?(domain) do
    case ExDisposable.Email.normalize_domain(domain) do
      nil ->
        false

      normalized_domain ->
        normalized_domain
        |> domain_candidates()
        |> Enum.any?(&MapSet.member?(@domains, &1))
    end
  end

  defp domain_candidates(normalized_domain) do
    domain_labels = String.split(normalized_domain, ".")

    for label_index <- 0..(length(domain_labels) - 1) do
      domain_labels
      |> Enum.drop(label_index)
      |> Enum.join(".")
    end
  end
end
