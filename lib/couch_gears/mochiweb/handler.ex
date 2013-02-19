defmodule CouchGears.Mochiweb.Handler do
  @moduledoc """
  This module is responsible for proxy passing incoming requests from a Couch DB to a gear application
  directly and sends response back to the Couch DB.
  """

  alias CouchGears.Records, as: Record

  @doc """
  Pushes a Couch DB request into the corresponding gear application
  """
  def call(nil, httpd, _db_name) do
    mochiweb_request = :erlang.element(2, httpd)
    { :ok, mochiweb_request.not_found() }
  end

  def call(app, httpd, db_name) do
    conn = app.service(CouchGears.Mochiweb.Connection.new(app, httpd, db_name))

    if conn.assigns[:exception] do
      { code, :error, exception, _stacktrace } = conn.assigns[:exception]
      { :ok, conn.send(code, exception.message) }
    else
      # if is_record(conn, CouchGears.Mochiweb.Connection) do
        # case conn.state do
        #   :set   -> { :ok, conn.send() }
        #   :unset -> { :ok, conn.send(500, "Missing response", conn) }
        #   :sent  -> { :ok, "Already sent" }
        # end
        { :ok, "success" }
      # else
        # raise "Expected 'service/1' function to return a CouchGears.Mochiweb.Connection, got #{inspect(conn)}"
      # end
    end
  end


  @doc """
  This function invoked from Couch DB directly and behaves as a `httpd_db_handlers` handler
  Check the `CouchGears.Initializer` module details.
  """
  def handle_db_gears_req(httpd, db) do
    { db_name, httpd } = { db_name(db), Record.Httpd.new(httpd) }

    app = Enum.find CouchGears.gears, fn(app) ->
      # seems not as good as should be!
      app_config = CouchGears.App.normalize_config(app)
      case app_config[:handlers][:dbs] do
        :all -> true
        list -> Enum.find list, fn(db) -> db_name == db end
      end
    end

    call(app, httpd, db_name)
  end

  @doc """
  Starts acceptance tests
  """
  def handle_global_gears_req(Record.Httpd[path_parts: ["_gears", "_test"]] = httpd) do
    CouchGears.Case.Acceptance.run
    { :ok, httpd.mochi_req.respond({"202", [], ""}) }
  end

  @doc """
  Restarts a `couch_gears` supervisor
  """
  def handle_global_gears_req(Record.Httpd[path_parts: ["_gears", "_restart"]] = httpd) do
    CouchGears.Initializer.restart
    { :ok, httpd.mochi_req.respond({"202", [], ""}) }
  end

  @doc """
  This function invokes from Couch DB directly and behave as a `httpd_global_handlers` handler
  Check the `CouchGears.Initializer` module details.
  """
  def handle_global_gears_req(Record.Httpd[path_parts: ["_gears" | _path_parts]] = httpd) do
    app = Enum.find CouchGears.gears, fn(app) ->
      # seems not as good as should be!
      app_config = CouchGears.App.normalize_config(app)
      app_config[:handlers][:global]
    end

    call(app, httpd, :_global)
  end

  def handle_global_gears_req(httpd), do: handle_global_gears_req(Record.Httpd.new(httpd))


  defp db_name(db), do: binary_to_atom(:erlang.element(15, db))
end