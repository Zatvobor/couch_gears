defmodule CouchGears.Filters.OnlyRequestTypeJSON do

  @doc false
  def service(conn, fun) do
    if conn.req_headers[:'Content-Type'] == "application/json" do
      conn = fun.(conn)
    else
      conn.send(400, "Bad Request")
    end

  end

end