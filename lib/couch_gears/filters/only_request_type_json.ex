defmodule CouchGears.Filters.OnlyRequestTypeJSON do
  @moduledoc """
  A convenience that passes request only with `Content-Type: application/json` header.
  Returns `404 Bad Request` otherwise.
  """

  @doc false
  def service(conn, fun) do
    if conn.req_headers("Content-Type") == "application/json" do
      conn = fun.(conn)
    else
      conn.send(400, "Bad Request")
    end
  end

end