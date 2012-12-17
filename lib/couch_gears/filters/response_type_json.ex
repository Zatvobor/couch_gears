defmodule CouchGears.Filters.ResponseTypeJSON do

  @doc false
  def prepare(conn) do
    conn.set_resp_header("Content-Type", "application/json")
  end

end