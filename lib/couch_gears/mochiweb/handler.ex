defmodule CouchGears.Mochiweb.Handler do

  def call(app, httpd, db_name) do
    conn = app.service(CouchGears.Mochiweb.HTTP.new(app, httpd, db_name))

    if is_record(conn, CouchGears.Mochiweb.HTTP) do
      case conn.state do
        :set   -> {:ok, conn.send}
        :unset -> {:ok, conn.send(500, "Missing response", conn)}
      end
    else
      raise "Expected service to return a CouchGears.Mochiweb.HTTP, got #{inspect conn}"
    end
  end
end