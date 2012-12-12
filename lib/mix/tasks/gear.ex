defmodule Mix.Tasks.Gear do
  use Mix.Task

  import Mix.Generator
  import Mix.Utils, only: [camelize: 1, underscore: 1]

  @version CouchGears.Mixfile.project[:version]
  @shortdoc "Create a new CouchGears' application"


  @moduledoc """
      mix gear - generates hello application
      mix gear application_name - generates specified application
  """
  def run(argv) do
    name = case argv do
      [] -> "hello_world"
      [name] -> name
    end

    path = File.join("apps", name)
    File.mkdir_p!(path)
    File.cd!(path, fn -> do_generate(name) end)
  end


  defp do_generate(name) do
    assigns = [version: @version, couch_gears_source: %b(path: "../../../couch_gears"), name: name]

    create_file ".gitignore", gitignore_text
    create_file "mix.exs",    mixfile_template(assigns)
    create_file "mix.lock",   mixlock_text

    create_directory "app"
    create_file "app/" <> name <>"_application.ex", lib_app_template(assigns)
    create_directory "app/routers"
    create_file "app/routers/application_router.ex", app_router_text

    create_directory "lib/mix/tasks"
    create_file "lib/mix/tasks/app.start", app_start_text
  end


  embed_text :gitignore, """
  /ebin
  /deps
  erl_crash.dump
  """

  embed_template :mixfile, """
  defmodule <%= Mix.Utils.camelize(@name) %>Application.Mixfile do
    use Mix.Project

    def project do
      [ app: :couch_gear_application,
        version: "0.1.0.dev",
        compile_path: "tmp/ebin",
        dynamos: [<%= Mix.Utils.camelize(@name) %>Application],
        compilers: [:elixir, :dynamo, :couch_gears, :app],
        source_paths: ["lib", "app"],
        env: [prod: [compile_path: "ebin"]],
        deps_path: "../../../couch_gears/deps",
        deps: deps ]
    end

    # Configuration for the OTP application
    def application do
      []
    end

    defp deps do
      [{:couch_gears, "<%= @version %>", <%= @couch_gears_source %>}]
    end
  end
  """

  embed_text :mixlock, from_file("../../../../mix.lock")

  embed_text :app_router, """
  defmodule ApplicationRouter do
    use CouchGears.Router

    get "/" do
      conn.resp_body("Yo")
    end
  end
  """

  embed_template :lib_app, """
  defmodule <%= Mix.Utils.camelize(@name) %>Application do
    use CouchGears

    # Application settings
    config :gear,
    # Application specific/aware db(s)
    # ["db_name"] available only for /db_name requests
    # :all enabled for various db(s)
    known_db: :all

    config :dynamo,
    # Compiles modules as they are needed
    compile_on_demand: false,
    # The environment this Dynamo runs on
    env: Mix.env


    endpoint ApplicationRouter

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