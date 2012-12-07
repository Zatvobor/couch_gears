defmodule CouchGears do

  defmodule Daemon do
    @doc """
    [daemons]
    couch_gears={'Elixir-CouchGears-Daemon', start_link, []}
    """
    def start_link() do
      append_code_paths
      start_otp_applications
    end


    @doc false
    defp append_code_paths do
      elixir_ebin = "/Volumes/branch320/opt/datahogs/couch_gears/deps/elixir/lib/elixir/ebin"
      :erlang.bitstring_to_list(elixir_ebin) /> :code.add_pathz

      Code.append_path("/Volumes/branch320/opt/datahogs/couch_gears/deps/dynamo/ebin")
      Code.append_path("/Volumes/branch320/opt/datahogs/couch_gears/deps/mimetypes/ebin")
    end

    @doc false
    defp start_otp_applications do
      :application.start(:elixir)
      Dynamo.start(:test)
      :application.start(:couch_gears)

      load_couch_gear_application
      {:ok, self()}
    end

    @doc false
    defp load_couch_gear_application do
      # Code.require_file("/opt/datahogs/hello_gear/lib/couch_gear_application.ex")
      Code.append_path("/Volumes/branch320/opt/datahogs/hello_gear/ebin")
      # CouchGearApplication.start
    end

  end

  defmodule HttpdDbHandlers do
    @doc """
    COUCH_GEARS_PA_OPTIONS="-pa /Volumes/branch320/opt/datahogs/couch_gears/ebin -pa /Volumes/branch320/opt/datahogs/hello_gears/ebin"
    [httpd_db_handlers]
    _gears = {'Elixir-CouchGears-HttpdDbHandlers', handle_db_gears_req}
    """
    def handle_db_gears_req(httpd, _db) do
      CouchGears.Mochiweb.Handler.call(CouchGearApplication, httpd, :undefined)
    end
  end


  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      use Dynamo
    end
  end

end
