defmodule CouchGears.Initializer do
  @moduledoc """
  This module is responsible for starting a CouchGears framework
  inside a particular Couch DB note as a independent daemon.

  A framework configuration designed as easy as possible. It follows
  a Couch DB extension rules.

  ## Configurtion

  1. Specify a CouchGears `ebin` path in `couchdb`.

    COUCH_GEARS_PA_OPTIONS="-pa /var/www/couch_gears/current/ebin"
    ERL_START_OPTIONS="$ERL_OS_MON_OPTIONS -sasl errlog_type error +K true +A 4 $COUCH_GEARS_PA_OPTIONS"

  2. Specify the `daemons` in `local.ini`

    [daemons]
    couch_gears={'Elixir-CouchGears-Initializer', start_link, [[{env, <<"prod">>}]]}

  Finally, notice that after initialization a CouchGears sets `httpd_db_handlers` option which handle
  incoming `_gears` requests.

  Is a equivalent to:

    [httpd_db_handlers]
    _gears = {'Elixir-CouchGears-Httpd-DbHandlers', handle_db_gears_req}

  """

  @root_path File.expand_path "../../..", __FILE__
  @httpd_db_handlers          "Elixir-CouchGears-Httpd-DbHandlers"
  @gears_request_prefix       "_gears"

  @doc """
  Starts CouchGears as a daemon
  """
  def start_link(opts) do
    configure_gears(opts)

    # Adds a Elixir deps to the code path
    :erlang.bitstring_to_list(@root_path <> "/deps/elixir/lib/elixir/ebin") /> :code.add_pathz

    Code.append_path(@root_path <> "/deps/elixir/lib/mix/ebin")
    Code.append_path(@root_path <> "/deps/elixir/lib/iex/ebin")

    # Adds a Dynamo deps to the code path
    Code.append_path(@root_path <> "/deps/dynamo/ebin")
    Code.append_path(@root_path <> "/deps/mimetypes/ebin")

    # Setups gears environment
    start_gears_dependencies
    configure_httpd_handlers
    initialize_gears

    {:ok, self()}
  end


  defp start_gears_dependencies do
    :application.start(:elixir)
    :application.start(:mix)
    :application.start(:mimetypes)
    :application.start(:dynamo)
  end

  defp configure_httpd_handlers do
    :couch_config.set(
      "httpd_db_handlers",
      "#{@gears_request_prefix}",
      "{'#{@httpd_db_handlers}', handle_db_gears_req}",
      false
    )
  end

  defp initialize_gears do
    apps = Enum.map File.wildcard(CouchGears.root_path <> "/apps/*"), fn(app_path) ->
      app_name = List.last(File.split(app_path))

      # Starts gear as an OTP application
      Code.append_path File.join([app_path, "ebin"])
      :application.start binary_to_atom(app_name)

      # Starts gear as an Dynamo application
      File.cd(app_path)
      Code.load_file File.join([app_path, "config", "application.ex"])
      app = Module.concat([Mix.Utils.camelize(app_name) <> "Application"])
      app.start_link
      app
    end

    CouchGears.gears(apps)
  end

  defp configure_gears(opts) do
    CouchGears.env(:couch_util.get_value(:env, opts, "dev"))
    CouchGears.root_path(@root_path)
  end
end