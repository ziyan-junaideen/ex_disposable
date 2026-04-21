defmodule Mix.Tasks.ExDisposable.SyncBlocklist do
  use Mix.Task

  @shortdoc "Downloads the upstream disposable email blocklist and opens a PR"
  @moduledoc """
  Downloads the latest upstream disposable email blocklist, bumps the package
  version, and opens a GitHub pull request for the release update.

  ## Usage

      mix ex_disposable.sync_blocklist

  The task requires a clean git worktree plus `git` and `gh` on `PATH`.
  """

  @impl Mix.Task
  def run(arguments) do
    case OptionParser.parse(arguments, strict: []) do
      {_options, [], []} ->
        sync_blocklist()

      _other ->
        Mix.raise("mix ex_disposable.sync_blocklist does not accept arguments")
    end
  end

  defp sync_blocklist do
    current_date = Date.utc_today()
    branch_name = ExDisposable.BlocklistUpdater.branch_name(current_date)
    commit_title = ExDisposable.BlocklistUpdater.commit_title(current_date)

    Mix.shell().info("Downloading the latest disposable email blocklist...")

    with :ok <- ensure_command_available("git"),
         :ok <- ensure_command_available("gh"),
         :ok <- ensure_clean_worktree(),
         {:ok, downloaded_blocklist_contents} <-
           ExDisposable.BlocklistUpdater.download_blocklist(),
         :ok <- checkout_main_branch(),
         :ok <- pull_main_branch(),
         {:ok, existing_blocklist_contents} <-
           ExDisposable.BlocklistUpdater.current_blocklist_contents(),
         true <-
           ExDisposable.BlocklistUpdater.blocklist_changed?(
             downloaded_blocklist_contents,
             existing_blocklist_contents
           ) do
      Mix.shell().info("A blocklist change was detected. Preparing an update branch...")

      with :ok <- ensure_branch_absent(branch_name),
           :ok <- create_branch(branch_name),
           {:ok, updated_version} <- write_updated_files(downloaded_blocklist_contents),
           :ok <- commit_changes(commit_title),
           :ok <- push_branch(branch_name),
           :ok <-
             create_pull_request(
               branch_name,
               commit_title,
               ExDisposable.BlocklistUpdater.pull_request_body(current_date, updated_version)
             ) do
        Mix.shell().info("Blocklist sync complete.")
      else
        {:error, reason} ->
          Mix.raise(reason)
      end
    else
      false ->
        Mix.shell().info("No blocklist changes detected after syncing `main`. Nothing to do.")

      {:error, reason} ->
        Mix.raise(reason)
    end
  end

  defp ensure_command_available(command_name) do
    if System.find_executable(command_name) do
      :ok
    else
      {:error, "Required executable not found on PATH: #{command_name}"}
    end
  end

  defp ensure_clean_worktree do
    Mix.shell().info("Checking for a clean git worktree...")

    case System.cmd("git", ["status", "--porcelain"], stderr_to_stdout: true) do
      {"", 0} ->
        :ok

      {status_output, 0} ->
        {:error,
         """
         Refusing to continue with a dirty git worktree.

         Please commit, stash, or discard these changes first:
         #{status_output}
         """}

      {status_output, exit_status} ->
        {:error, command_failure_message("git status --porcelain", exit_status, status_output)}
    end
  end

  defp checkout_main_branch do
    Mix.shell().info("Checking out `main`...")
    run_command("git", ["checkout", "main"])
  end

  defp pull_main_branch do
    Mix.shell().info("Pulling the latest changes for `main`...")
    run_command("git", ["pull", "--ff-only"])
  end

  defp ensure_branch_absent(branch_name) do
    Mix.shell().info("Ensuring `#{branch_name}` does not already exist...")

    case System.cmd("git", ["rev-parse", "--verify", "--quiet", branch_name],
           stderr_to_stdout: true
         ) do
      {"", 1} ->
        :ok

      {output, 0} ->
        {:error,
         """
         Branch `#{branch_name}` already exists.

         Existing reference:
         #{output}
         """}

      {output, exit_status} ->
        {:error,
         command_failure_message(
           "git rev-parse --verify --quiet #{branch_name}",
           exit_status,
           output
         )}
    end
  end

  defp create_branch(branch_name) do
    Mix.shell().info("Creating branch `#{branch_name}` from `main`...")
    run_command("git", ["checkout", "-b", branch_name])
  end

  defp write_updated_files(downloaded_blocklist_contents) do
    Mix.shell().info("Writing #{ExDisposable.BlocklistUpdater.blocklist_path()}...")
    File.mkdir_p!(Path.dirname(ExDisposable.BlocklistUpdater.blocklist_path()))
    File.write!(ExDisposable.BlocklistUpdater.blocklist_path(), downloaded_blocklist_contents)

    Mix.shell().info(
      "Bumping the library version in #{ExDisposable.BlocklistUpdater.mix_exs_path()}..."
    )

    mix_exs_contents = File.read!(ExDisposable.BlocklistUpdater.mix_exs_path())

    with {:ok, updated_mix_exs_contents, previous_version, updated_version} <-
           ExDisposable.BlocklistUpdater.update_mix_exs_version(mix_exs_contents) do
      File.write!(ExDisposable.BlocklistUpdater.mix_exs_path(), updated_mix_exs_contents)

      Mix.shell().info("Version updated from #{previous_version} to #{updated_version}.")
      {:ok, updated_version}
    end
  end

  defp commit_changes(commit_title) do
    Mix.shell().info("Staging updated files...")

    with :ok <-
           run_command("git", [
             "add",
             ExDisposable.BlocklistUpdater.blocklist_path(),
             ExDisposable.BlocklistUpdater.mix_exs_path()
           ]) do
      Mix.shell().info("Creating commit `#{commit_title}`...")
      run_command("git", ["commit", "-m", commit_title])
    end
  end

  defp push_branch(branch_name) do
    Mix.shell().info("Pushing `#{branch_name}` to `origin`...")
    run_command("git", ["push", "-u", "origin", branch_name])
  end

  defp create_pull_request(branch_name, title, body) do
    Mix.shell().info("Creating a GitHub pull request with `gh`...")

    run_command("gh", [
      "pr",
      "create",
      "--base",
      "main",
      "--head",
      branch_name,
      "--title",
      title,
      "--body",
      body
    ])
  end

  defp run_command(command_name, arguments) do
    rendered_command = Enum.join([command_name | arguments], " ")
    Mix.shell().info("$ #{rendered_command}")

    case System.cmd(command_name, arguments, stderr_to_stdout: true) do
      {command_output, 0} ->
        maybe_print_output(command_output)
        :ok

      {command_output, exit_status} ->
        {:error, command_failure_message(rendered_command, exit_status, command_output)}
    end
  end

  defp maybe_print_output(""), do: :ok

  defp maybe_print_output(command_output) do
    Mix.shell().info(command_output)
  end

  defp command_failure_message(rendered_command, exit_status, command_output) do
    """
    Command failed: #{rendered_command}
    Exit status: #{exit_status}

    #{String.trim(command_output)}
    """
  end
end
