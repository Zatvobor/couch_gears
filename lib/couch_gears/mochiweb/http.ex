Code.prepend_path("deps/couchdb/src/couchdb")

defmodule CouchGears.Mochiweb.HTTP do

  defrecord Httpd, Record.extract(:httpd, from: "couch_db.hrl")
  use Dynamo.HTTP.Behaviour, [:httpd, :db_name]


  @doc false
  def new(app, httpd, db_name) do
    # convert to Elixir's record
    httpd = Httpd.new(httpd)

    connection(
      app: app,
      httpd: httpd,
      db_name: db_name,
      path_info_segments: path_info_segments(httpd),
      method: original_method(httpd),
      before_send: Dynamo.HTTP.default_before_send
    )
  end

  # def new(app) do
  #   connection(app: app)
  # end

  # Connection helpers

  def path_info_segments(httpd) do
    [_a,_b | path_parts] = httpd.path_parts
    path_parts
  end

  def original_method(httpd), do: atom_to_binary(httpd.method, :utf8)

  # def query_string(httpd) do
  #   raw_path = h.mochi_req.get(:raw_path)
  #   {_, query_string, _} = :mochiweb_util.urlsplit_path(raw_path)
  #   query_string
  # end


  # Should be checked and removed/redefined

  def query_string(_a), do: raise "unexpected behaviour"

  def path_segments(_a), do: raise "unexpected behaviour"
  def path(_a), do: raise "unexpected behaviour"
  def version(_a), do: raise "unexpected behaviour"
  def req_cookies(_a), do: raise "unexpected behaviour"


  # Response haldlers

  def send(code, body, connection) do
    connection(httpd: httpd, resp_headers: headers, resp_cookies: cookies) = connection
    httpd.mochi_req.respond({code, CouchGears.Mochiweb.Utils.get_resp_headers(headers, cookies), body})
  end

  def fetch(_a,_b), do: raise "unexpected behaviour"
  def sendfile(_a,_b), do: raise "unexpected behaviour"
  def chunk(_a,_b), do: raise "unexpected behaviour"
  def send_chunked(_a,_b), do: raise "unexpected behaviour"
end