defmodule CouchGears.Mochiweb.Handler do
  @moduledoc """
  This module is responsible for passing request environment to the gear application
  directly and sends response back.
  """

  @doc false
  def call(app, httpd, db_name) do
    conn = app.service(CouchGears.Mochiweb.HTTP.new(app, httpd, db_name))

    if is_record(conn, CouchGears.Mochiweb.HTTP) do
      case conn.state do
        :set   -> { :ok, conn.send }
        :unset -> { :ok, conn.send(500, "Missing response", conn) }
      end
    else
      raise "Expected 'service/1' function to return a CouchGears.Mochiweb.HTTP, got #{inspect(conn)}"
    end
  end
end