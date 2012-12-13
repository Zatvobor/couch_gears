defmodule CouchGears.Initializer do

  @doc """
  COUCH_GEARS_PA_OPTIONS="-pa /Volumes/branch320/opt/datahogs/couch_gears/ebin"
  [daemons]
  couch_gears={'Elixir-CouchGears-Initializer', start_link, [[{env, <<"prod">>},{root_path, <<"/Volumes/branch320/opt/datahogs/couch_gears">>}]]}
  """
  def start_link(opts) do
    # Assert start up options
    {_, root_path} = configure_gears(opts)

    # Firstly set up load paths for Elixir
    :erlang.bitstring_to_list(root_path <> "/deps/elixir/lib/elixir/ebin") /> :code.add_pathz


    # Then Elixir's stuff are available
    Code.append_path(root_path <> "/deps/elixir/lib/mix/ebin")
    Code.append_path(root_path <> "/deps/elixir/lib/iex/ebin")
    Code.append_path(root_path <> "/deps/dynamo/ebin")
    Code.append_path(root_path <> "/deps/mimetypes/ebin")

    # Set up gears environment
    start_gears_dependencies
    configure_httpd_handlers
    initialize_gears

    # Notify couch's supervisor about success
    {:ok, self()}
  end



  defp start_gears_dependencies do
    :application.start(:elixir)
    :application.start(:mix)
    :application.start(:mimetypes)
    :application.start(:dynamo)
  end

  defp configure_httpd_handlers do
    # [httpd_db_handlers]
    # _gears = {'Elixir-CouchGears-Httpd-DbHandlers', handle_db_gears_req}
    :couch_config.set("httpd_db_handlers", "_gears", "{'Elixir-CouchGears-Httpd-DbHandlers', handle_db_gears_req}", false)
  end

  defp initialize_gears do
    apps = Enum.map File.wildcard(CouchGears.root_path <> "/apps/*"), fn(app_path) ->
      File.cd(app_path)
      Code.load_file File.join([app_path, "config", "application.ex"])

      app_name = Mix.Utils.camelize List.last(File.split(app_path))
      app = Module.concat([app_name <> "Application"])
      app.start_link
      app
    end

    :application.set_env(:couch_gears, :gears, apps)
  end

  defp configure_gears(opts) do
    env = :couch_util.get_value(:env, opts, "dev")
    CouchGears.env(env)

    root_path = :couch_util.get_value(:root_path, opts)
    CouchGears.root_path(root_path)

    if root_path == :undefined, do: raise "undefined root_path"

    {env, root_path}
  end

end