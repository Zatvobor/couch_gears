defmodule CouchGears.Initializer do

  @root_path File.expand_path "../../..", __FILE__

  @doc """
  COUCH_GEARS_PA_OPTIONS="-pa /Volumes/branch320/opt/datahogs/couch_gears/ebin"
  [daemons]
  couch_gears={'Elixir-CouchGears-Initializer', start_link, [[{env, <<"prod">>}]]}
  """
  def start_link(opts) do
    configure_gears(opts)

    # Firstly setup a load path for Elixir
    :erlang.bitstring_to_list(@root_path <> "/deps/elixir/lib/elixir/ebin") /> :code.add_pathz

    # Appends runtime dependencies
    Code.append_path(@root_path <> "/deps/elixir/lib/mix/ebin")
    Code.append_path(@root_path <> "/deps/elixir/lib/iex/ebin")
    Code.append_path(@root_path <> "/deps/dynamo/ebin")
    Code.append_path(@root_path <> "/deps/mimetypes/ebin")

    # Setups gears environment
    start_gears_dependencies
    configure_httpd_handlers
    initialize_gears

    # Notifies couch's supervisor about success
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
      app_name = List.last(File.split(app_path))

      # Starts OTP application
      Code.append_path File.join([app_path, "ebin"])
      :application.start binary_to_atom(app_name)

      # Starts dynamos application
      File.cd(app_path)
      Code.load_file File.join([app_path, "config", "application.ex"])
      app = Module.concat([Mix.Utils.camelize(app_name) <> "Application"])
      app.start_link
      app
    end

    # Registers loaded applications
    CouchGears.gears(apps)
  end

  defp configure_gears(opts) do
    CouchGears.env(:couch_util.get_value(:env, opts, "dev"))
    CouchGears.root_path(@root_path)
  end
end