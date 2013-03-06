defmodule CouchGears.Mochiweb.BodyParser do
  @moduledoc false

  @doc false
  def parse(conn) do
    { content_type, body } = { conn.req_headers("Content-Type"), conn.raw_req_body }
    parse_body(content_type, body)
  end

  @doc false
  def parse_body("application/json", body) do
    JSON.decode body
  end

  @doc false
  def parse_body(_, body), do: body
end