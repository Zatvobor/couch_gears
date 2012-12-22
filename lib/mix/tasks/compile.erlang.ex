defmodule Mix.Tasks.Compile.Erlang do
  use Mix.Task

  @hidden true
  @shortdoc "Compile Erlang source files"

  @moduledoc """
  A task to compile Erlang source files.

  ## Command line options
  * `ERL_COMPILER_OPTIONS` - can be used to give default compile options.
     It's value must be a valid Erlang term. If the value is a list, it will
     be used as is. If it is not a list, it will be put into a list.

  ## Configuration

  * `:erlangrc_options` - compilation options that applies
     to Erlangs's compiler, they are: `[verbose,report_errors,report_warnings]`
     by default.
  """
  def run(_) do
    compile_path = Mix.project[:compile_path] /> File.expand_path /> binary_to_list

    erlangrc_options = Mix.project[:erlangrc_options] || [:verbose, :report_errors, :report_warnings]
    erlangrc_options = erlangrc_options ++ [{:outdir, compile_path}]

    files = Mix.Utils.extract_files(Mix.project[:source_paths], [:erl])

    Enum.each files, fn(file) ->
      file = String.replace(file, ".erl", "") /> File.expand_path /> binary_to_list

      case :compile.file(file, erlangrc_options) do
        {:ok, _} -> IO.puts "Compiled #{file}.erl"
        :error   -> IO.puts "== Compilation error on file #{file}.erl"
      end
    end
  end

end
