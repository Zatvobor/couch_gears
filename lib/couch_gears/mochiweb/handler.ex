defmodule CouchGears.Mochiweb.Handler do
  @moduledoc """
  This module is responsible for proxy passing incoming requests from a Couch DB to a gear application
  directly and sends response back to the Couch DB.
  """

  @doc """
  Pushes a Couch DB request into the corresponding gear application
  """
  def call(nil, httpd, _db_name) do
    mochiweb_request = :erlang.element(2, httpd)
    { :ok, mochiweb_request.not_found() }
  end

  def call(app, httpd, db_name) do
    conn = app.service(CouchGears.Mochiweb.Connection.new(app, httpd, db_name))

    if is_record(conn, CouchGears.Mochiweb.Connection) do
      # case conn.state do
      #   :set   -> { :ok, conn.send() }
      #   :unset -> { :ok, conn.send(500, "Missing response", conn) }
      #   :sent  -> { :ok, "Already sent" }
      # end
      { :ok, "success" }
    else
      raise "Expected 'service/1' function to return a CouchGears.Mochiweb.Connection, got #{inspect(conn)}"
    end
  end


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

  @doc """
  This function invoked from Couch DB directly and behaves as a `httpd_global_handlers` handler
  Check the `CouchGears.Initializer` module details.
  """
  def handle_global_gears_req(httpd) do
    app = Enum.find CouchGears.gears, fn(app) ->
      # seems not as good as should be!
      app_config = CouchGears.App.normalize_config(app)
      app_config[:handlers][:global]
    end

    call(app, httpd, :_global)
  end


  defp db_name(db), do: binary_to_atom(:erlang.element(15, db))
end