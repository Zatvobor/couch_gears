defmodule Mix.Tasks.Gear do
  use Mix.Task

  import Mix.Generator
  import Mix.Utils, only: [camelize: 1, underscore: 1]

  @version CouchGears.Mixfile.project[:version]
  @shortdoc "Create a new CouchGears project"


  @moduledoc """
      mix gear hello_gear
  """
  def run(argv) do
    { opts, argv } = OptionParser.parse(argv, flags: [:dev])
    case argv do
      [] ->
        raise Mix.Error, message: "expected PATH to be given, please use `mix gears PATH`"
      [path] ->
        File.mkdir_p!(path)
        File.cd!(path, fn -> do_generate(opts) end)
    end
  end


  defp do_generate(opts) do

    couch_gears_source = if opts[:dev] do
      %b(raw: "#{File.expand_path("../../../..", __FILE__)}")
    else
      %b(github: "datahogs/couch_gears")
    end

    assigns = [version: @version, couch_gears_source: couch_gears_source]

    create_file ".gitignore", gitignore_text
    create_file "Makefile",   makefile_text
    create_file "mix.exs",    mixfile_template(assigns)

    create_directory "app"
    create_directory "app/routers"
    create_file "app/routers/application_router.ex", app_router_text

    create_directory "lib"
    create_file "lib/couch_gear_application.ex", lib_app_text
    create_directory "lib/mix/tasks"
    create_file "lib/mix/tasks/app.start", app_start_text
  end


  embed_text :gitignore, """
  /ebin
  /deps
  erl_crash.dump
  """

  embed_text :makefile, from_file("../../../../Makefile")

  embed_template :mixfile, """
  defmodule CouchGearApplication.Mixfile do
    use Mix.Project

    def project do
      [ app: :couch_gear_application,
        version: "0.0.1.dev",
        compile_path: "tmp/ebin",
        dynamos: [CouchGearApplication],
        compilers: [:elixir, :dynamo, :couch_gears, :app],
        env: [prod: [compile_path: "ebin"]],
        deps: deps ]
    end

    # Configuration for the OTP application
    def application do
      [ applications: [:dynamo] ]
    end

    defp deps do
      [ {:couch_gears, "<%= @version %>", <%= @couch_gears_source %>} ]
    end
  end
  """

  embed_text :app_router, """
  defmodule ApplicationRouter do
    use CouchGears.Router

    get "/" do
      conn.resp_body("Yo")
    end
  end
  """

  embed_text :lib_app, """
  defmodule CouchGearApplication do
    use CouchGears

    endpoint ApplicationRouter

    config :dynamo,
    # Compiles modules as they are needed
    compile_on_demand: false,
    # The environment this Dynamo runs on
    env: Mix.env

  end
  """

  embed_text :app_start, """
  defmodule Mix.Tasks.App.Start do
    use Mix.Task

    @hidden true
    @shortdoc "Run all Dynamos in a web server"

    def run(_) do
      IO.puts "Application has been started (fake)"
    end

  end
  """
end