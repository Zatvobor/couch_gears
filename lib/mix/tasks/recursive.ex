defmodule Mix.Tasks.Recursive do
  @moduledoc """
  Executes the commands separated by comma for each application under `:apps_path`.

  ## Examples

  The example below prints the available compilers and
  then the list of dependencies.

      mix recursive compile --list, deps

  """

  @shortdoc "Executes the commands recursively for each application under :apps_path"

  use Mix.Task

  def run(args) do
    unless Mix.project[:apps_path], do: raise Mix.Error, message: "no :apps_path expression"
    apps_path = [Path.expand(".")] ++ Path.wildcard(Path.join([Path.expand(Mix.project[:apps_path]), "*"]))

    Enum.each(gather_commands(args), function do
      [task|args] -> run(task, args, apps_path)
      [] -> raise Mix.Error, message: "no expression between commas"
    end)
  end

  defp run(task, args, apps_path) when is_list(apps_path) do
    Enum.each(apps_path, fn app_path -> run(task, args, app_path) end)
  end

  defp run(task, args, app_path) do
    mix_path = Path.join [app_path, "mix.exs"]
    if File.regular?(mix_path) do
      Mix.shell.info("==> " <> app_path <> " (" <> task <> ")")

      File.cd(app_path)
      Code.load_file(mix_path)
      Mix.Server.call(:clear_tasks)

      try do
        Mix.Task.run(task, args)
      rescue
        exception -> Mix.shell.error(exception.message)
      end
    end
  end

  # Copied from elixir code (temporary)
  defp gather_commands(args) do
    gather_commands args, [], []
  end

  defp gather_commands([h|t], current, acc) when binary_part(h, byte_size(h), -1) == "," do
    part    = binary_part(h, 0, byte_size(h) - 1)
    current = Enum.reverse([part|current])
    gather_commands t, [], [current|acc]
  end

  defp gather_commands([h|t], current, acc) do
    gather_commands t, [h|current], acc
  end

  defp gather_commands([], current, acc) do
    Enum.reverse [Enum.reverse(current)|acc]
  end
end