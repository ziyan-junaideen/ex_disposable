defmodule ExDisposable.BlocklistUpdaterTest do
  use ExUnit.Case, async: true

  test "bump_patch_version/1 increments the last version segment" do
    assert {:ok, "0.1.1"} = ExDisposable.BlocklistUpdater.bump_patch_version("0.1.0")
  end

  test "update_mix_exs_version/1 replaces the project version" do
    mix_exs_contents = """
    defmodule Example.MixProject do
      use Mix.Project

      def project do
        [
          app: :example,
          version: "1.2.3"
        ]
      end
    end
    """

    assert {:ok, updated_mix_exs_contents, "1.2.3", "1.2.4"} =
             ExDisposable.BlocklistUpdater.update_mix_exs_version(mix_exs_contents)

    assert updated_mix_exs_contents =~ ~s(version: "1.2.4")
    refute updated_mix_exs_contents =~ ~s(version: "1.2.3")
  end

  test "branch_name/1 and commit_title/1 use the provided date" do
    update_date = ~D[2026-04-20]

    assert ExDisposable.BlocklistUpdater.branch_name(update_date) ==
             "blocklist-update-2026-04-20"

    assert ExDisposable.BlocklistUpdater.commit_title(update_date) ==
             "Update disposable email blocklist (2026-04-20)"
  end

  test "blocklist_changed?/2 reports whether the contents differ" do
    refute ExDisposable.BlocklistUpdater.blocklist_changed?("same", "same")
    assert ExDisposable.BlocklistUpdater.blocklist_changed?("new", "old")
    assert ExDisposable.BlocklistUpdater.blocklist_changed?("new", nil)
  end
end
