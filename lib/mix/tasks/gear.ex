defmodule Mix.Tasks.Gear do

  @moduledoc """
      mix gear - generates hello application
      mix gear application_name - generates specified application
  """

  @version CouchGears.Mixfile.project[:version]
  @shortdoc "Create a new CouchGears' application"

  use Mix.Task

  import Mix.Generator
  import Mix.Utils, only: [camelize: 1, underscore: 1]


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

    create_directory "config"
    create_file "config/application.ex", app_template(assigns)

    create_directory "app/routers"
    create_file "app/routers/application_router.ex", app_router_text

    create_directory "test/" <> name
    create_file "test/test_helper.exs", test_helper_text
    create_file "test/" <> name <> "/application_router_test.exs", application_router_test_text
  end


  embed_text :gitignore, """
  /ebin
  /deps
  erl_crash.dump
  """

  embed_template :mixfile, """
  defmodule <%= Mix.Utils.camelize(@name) %>Application.Mixfile do
    use Mix.Project

    @doc false
    def project do
      [ app: :<%= @name %>,
        version: <%= @version %>,
        compilers: [:elixir, :app],
        deps_path: "../../../couch_gears/deps",
        deps: deps ]
    end


    defp deps do
      [{:couch_gears, "<%= @version %>", <%= @couch_gears_source %>}]
    end
  end
  """

  embed_text :mixlock, from_file("../../../../mix.lock")
  embed_text :test_helper, from_file("../../../../test/test_helper.exs")

  embed_text :app_router, """
  defmodule ApplicationRouter do
    use CouchGears.Router

    # Application level filters

    # Sets CouchGears backend version info as a 'Server' response header
    # filter CouchGears.Filters.ServerVersion

    # Sets 'application/json' by default
    filter CouchGears.Filters.ResponseTypeJSON

    # Accepts only 'application/json' requests. Otherwise, returns a 'Bad Request' response
    # filter CouchGears.Filters.OnlyRequestTypeJSON


    get "/" do
      conn.resp_body([{:ok, "Hello World"}], :json)
    end
  end
  """

  embed_template :app, """
  defmodule <%= Mix.Utils.camelize(@name) %>Application do
    use CouchGears

    config :gear,
    # The dbs that enabled for application
    known_db: :all


    config :dynamo,
    # Compiles modules as they are needed
    # compile_on_demand: true,
    # Reload modules after they are changed
    # reload_modules: true,

    # The environment this Dynamo runs on
    env: CouchGears.env,

    # The endpoint to dispatch requests too
    endpoint: ApplicationRouter


    # The environment's specific options
    environment "dev" do
      config :dynamo, compile_on_demand: true, reload_modules: true
    end

    environment %r(prod|test) do
      config :dynamo, compile_on_demand: true, reload_modules: false
    end
  end
  """

  embed_text :application_router_test, """
  Code.require_file "../../test_helper.exs", __FILE__

  defmodule ApplicationRouterTest do
    use ExUnit.Case, async: true
    use CouchGears.Case

    Code.require_file "app/routers/application_router.ex"
    @app ApplicationRouter


    test "returns not_found" do
      assert get(path: "u/n/k/n/o/w/n").status == 404
    end

    test "returns body as json" do
      conn = get(path: "/", headers: [{"Content-Type", "application/json"}])

      assert conn.status == 200
      assert conn.resp_headers("Content-Type") == "application/json"
      assert conn.resp_body == "{\\"ok\\":\\"Hello World\\"}"
    end

  end
  """
end