defmodule CouchGears.Initializers do

  @doc """
  COUCH_GEARS_PA_OPTIONS="-pa /Volumes/branch320/opt/datahogs/couch_gears/ebin"
  [daemons]
  couch_gears={'Elixir-CouchGears-Initializers', start_link, [<<"/Volumes/branch320/opt/datahogs/couch_gears">>]}
  """
  def start_link(root_path) do
    # Firstly set up load paths for Elixir
    :erlang.bitstring_to_list(root_path <> "/deps/elixir/lib/elixir/ebin") /> :code.add_pathz

    # Then Elixir's stuff are available
    Code.append_path(root_path <> "/deps/elixir/lib/mix/ebin")
    Code.append_path(root_path <> "/deps/dynamo/ebin")
    Code.append_path(root_path <> "/deps/mimetypes/ebin")

    # Set up gears environment
    start_gears_dependencies
    configure_httpd_handlers
    initialize_gears(root_path)

    # Notify couch's supervisor about success
    {:ok, self()}
  end


  @doc false
  defp start_gears_dependencies do
    :application.start(:elixir)
    :application.start(:mimetypes)
    :application.start(:dynamo)
  end

  @doc false
  defp configure_httpd_handlers do
    # [httpd_db_handlers]
    # _gears = {'Elixir-CouchGears-Httpd-DbHandlers', handle_db_gears_req}
    :couch_config.set("httpd_db_handlers", "_gears", "{'Elixir-CouchGears-Httpd-DbHandlers', handle_db_gears_req}", false)
  end

  @doc false
  defp initialize_gears(root_path) do
    apps = Enum.map File.wildcard(root_path <> "/apps/*"), fn(app_path) ->
      # should check compile_on_demand and current environment...
      # for dev|test env should re(load|compile) whole application by request
      # for prod env load/compile whole application
      Code.append_path(app_path <> "/tmp/ebin")

      app_name = Mix.Utils.camelize List.last(File.split(app_path))
      app = Module.concat([app_name <> "Application"])
      app.start
      app
    end

    :application.set_env(:couch_gears, :gears, apps)
  end

end