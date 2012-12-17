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
      params: query_string(httpd),
      req_headers: req_headers(httpd),
      cookies: cookies(httpd),
      before_send: Dynamo.HTTP.default_before_send
    )
  end


  # Connection helpers

  def path_info_segments(httpd) do
    # cuts 'db_name' and '_gears' parts
    [_a,_b | path_parts] = httpd.path_parts
    path_parts
  end

  def original_method(httpd) do
    atom_to_binary(httpd.method, :utf8)
  end

  def query_string(httpd) do
    Enum.map httpd.mochi_req.parse_qs, fn({k, v}) -> {list_to_atom(k), list_to_binary(v)} end
  end

  def req_headers(httpd) do
    headers = :mochiweb_headers.to_list(httpd.mochi_req.get(:headers))
    Enum.map headers, fn({k, v}) -> {k, list_to_binary(v)} end
  end

  def cookies(httpd) do
    Enum.map httpd.mochi_req.parse_cookie, fn({k, v}) -> {list_to_atom(k), list_to_binary(v)} end
  end


  # Should be checked and removed/redefined

  def path_segments(_a), do: panic!
  def path(_a), do: panic!
  def version(_a), do: panic!
  def req_cookies(_a), do: panic!


  # Response handlers

  def resp_body(props, :json, conn) when is_list(props) do
    conn.resp_body(:ejson.encode({props}))
  end

  def send(code, body, connection) do
    connection(httpd: httpd, resp_headers: headers, resp_cookies: cookies) = connection
    httpd.mochi_req.respond({code, CouchGears.Mochiweb.Utils.get_resp_headers(headers, cookies), body})
  end

  def fetch(_a,_b), do: panic!
  def sendfile(_a,_b), do: panic!
  def chunk(_a,_b), do: panic!
  def send_chunked(_a,_b), do: panic!


  defp panic! do
    raise "Something wrong with it. Submit the github/issue, please"
  end

end