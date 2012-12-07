defmodule Mix.Tasks.Compile.Couch_gears do
  use Mix.Task

  # @hidden true
  @shortdoc "Compile Couch Gear Application source files"


  def run(_) do
    Mix.Task.run "compile.dynamo"
  end

end
