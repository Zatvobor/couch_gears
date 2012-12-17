defmodule CouchGears.Filters.ServerVersion do

  @doc false
  def prepare(conn) do
    conn.set_resp_header("Server", "CouchGears/" <> CouchGears.version)
  end

end