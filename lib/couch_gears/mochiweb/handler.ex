defmodule CouchGears.Mochiweb.Handler do
  @moduledoc """
  This module is responsible for proxy passing incoming requests from a Couch DB to a gear application
  directly and sends response back to the Couch DB.
  """

  @doc """
  Pushes a Couch's request into the corresponding gear application
  """
  def call(nil, httpd, db_name) do
    raise "Could not find the corresponding gear application"
  end

  def call(app, httpd, db_name) do
    conn = app.service(CouchGears.Mochiweb.Connection.new(app, httpd, db_name))

    if is_record(conn, CouchGears.Mochiweb.Connection) do
      case conn.state do
        :set   -> { :ok, conn.send() }
        :unset -> { :ok, conn.send(500, "Missing response", conn) }
        :sent  -> { :ok, "Already sent" }
      end
    else
      raise "Expected 'service/1' function to return a CouchGears.Mochiweb.Connection, got #{inspect(conn)}"
    end
  end


  # Couch DB httpd handlers

  @doc """
  This function invoked from Couch DB directly and behaves as a `httpd_db_handlers` handler
  Check the `CouchGears.Initializer` module details.
  """
  def handle_db_gears_req(httpd, db) do
    req_db_name = db_name(db)

    app = Enum.find CouchGears.gears, fn(app) ->
      # seems not as good as should be!
      app_config = CouchGears.App.normalize_config(app)
      case app_config[:handlers][:dbs] do
        :all -> true
        list -> Enum.find list, fn(db) -> req_db_name == db end
      end
    end

    call(app, httpd, req_db_name)
  end


  defp db_name(db), do: binary_to_atom(:erlang.element(15, db))
end