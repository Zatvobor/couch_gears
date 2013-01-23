defmodule CouchGears.Filters.ResponseTypeJSON do
  @moduledoc """
  A filter that sets response `Content-Type: application/json` header.
  """


  @doc false
  def prepare(conn) do
    conn.put_resp_header("Content-Type", "application/json")
  end

end