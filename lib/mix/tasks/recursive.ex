defmodule Mix.Tasks.Recursive do
  @moduledoc false

  @shortdoc "Executes the commands recursively for each application under :app_path"

  use Mix.Task

  def run(args) do
    unless Mix.project[:apps_path], do: raise Mix.Error, message: "no :apps_path expression"
    apps_path = Path.wildcard(Path.join([Path.expand(Mix.project[:apps_path]), "*"]))

    Enum.each(Mix.Tasks.Do.gather_commands(args), function do
      [task|args] -> run(task, args, apps_path)
      []          -> raise Mix.Error, message: "no expression between commas"
    end)
  end

  defp run(task, args, apps_path) when is_list(apps_path) do
    Enum.each([Path.expand(".")] ++ apps_path, fn app_path ->
      run(task, args, app_path)
    end)
  end

  defp run(task, args, app_path) do
    mix_path = Path.join [app_path, "mix.exs"]
    if File.regular?(mix_path) do
      try do
        Code.require_file(mix_path)
        Mix.Task.run(task, args)
      rescue
        exception -> Mix.shell.error(exception.message)
      end
    end
  end
end