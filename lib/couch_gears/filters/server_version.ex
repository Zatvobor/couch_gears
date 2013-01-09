defmodule CouchGears.Filters.ServerVersion do
  @moduledoc """
  A filter that sets CouchGears current version as a `Server` response header
  for each response.
  """

  @doc false
  def prepare(conn) do
    conn.set_resp_header("Server", "CouchGears/" <> CouchGears.version)
  end

end