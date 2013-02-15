defmodule CouchGears.Mochiweb.Connection do
  @moduledoc false

  use Dynamo.Connection.Behaviour, [:httpd, :database]


  @doc false
  def new(app, httpd, db_name) do
    database = to_binary(db_name)

    unless db_name == :under_test || db_name == :_global do
      database = CouchGears.Database.open(database)
    end

    connection(
      app: app,
      httpd: httpd,
      database: database,

      path_info_segments: path_info_segments(httpd),
      method: original_method(httpd),

      params: query_string(httpd),

      req_headers: req_headers(httpd),
      req_cookies: req_cookies(httpd),

      before_send: Dynamo.Connection.default_before_send
    )
  end

  @doc """
  Gets a Couch DB request record. Check a `#httpd` record from the `include/couch_db.hrl`
  for record properties.
  """
  def httpd(connection(httpd: httpd)), do: httpd

  # Request

  @doc false
  def version(connection(httpd: httpd)) do
    httpd.mochi_req.get(:version)
  end

  @doc false
  def scheme(connection(httpd: httpd)) do
    httpd.mochi_req.get(:scheme)
  end

  @doc false
  def host(conn) do
    # Host = "Host" ":" host [ ":" port ] ; Section 3.2.2
    req_headers("Host", conn)
  end

  @doc false
  def path(connection(httpd: httpd)) do
    httpd.mochi_req.get(:raw_path)
  end

  @doc false
  def path_segments(connection(httpd: httpd)) do
    httpd.path_parts
  end

  @doc false
  def path_info_segments(httpd) do
    # cuts 'db_name' and '_gears' parts from the application `path_parts` environment
    case httpd.path_parts do
      # applies `:dbs` aware request
      [_a, "_gears" | path_parts] -> path_parts
      # applies `:global` awaare request
      ["_gears" | path_parts]     -> path_parts
    end
  end

  @doc false
  def original_method(httpd) do
    atom_to_binary(httpd.method, :utf8)
  end

  @doc false
  def query_string(httpd) do
    Enum.map httpd.mochi_req.parse_qs, fn({k, v}) -> {list_to_atom(k), list_to_binary(v)} end
  end

  # Headers

  @doc false
  def req_headers(key, connection(req_headers: req_headers)) do
    :proplists.get_value(key, req_headers)
  end

  @doc false
  def resp_headers(key, connection(resp_headers: resp_headers)) do
    {_,resp_headers} = resp_headers
    :proplists.get_value(key, resp_headers)
  end

  @doc false
  def req_headers(httpd) do
    headers = :mochiweb_headers.to_list(httpd.mochi_req.get(:headers))
    Enum.map headers, fn({k, v}) -> {to_binary(k), to_binary(v)} end
  end

  # Cookies

  @doc false
  def req_cookies(httpd) do
    Enum.map httpd.mochi_req.parse_cookie, fn({k, v}) -> {list_to_atom(k), list_to_binary(v)} end
  end

  # Response API

  @doc false
  def already_sent?(connection(app: :under_test, state: state)) do
    state == :set
  end

  @doc false
  def already_sent?(connection(state: state)) do
    state == :sent
  end

  @doc false
  def resp_body(props, :json, conn) when is_list(props) do
    conn.resp_body(:ejson.encode({props}))
  end

  @doc false
  def send(code, body, connection) do
    connection(httpd: httpd, resp_headers: headers, resp_cookies: cookies) = connection

    merged_headers    = CouchGears.Mochiweb.Utils.get_resp_headers(headers, cookies)
    mochiweb_response = httpd.mochi_req.respond({code, merged_headers, body})

    connection(connection,
      resp_body: nil,
      status: mochiweb_response.get(:code),
      state: :sent)
  end



  # Pending/Not yet implemented

  def fetch(_a,_b), do: panic!
  def sendfile(_a,_b), do: panic!
  def chunk(_a,_b), do: panic!
  def send_chunked(_a,_b), do: panic!


  defp panic! do
    raise "Something wrong with it. Submit the github/issue, please"
  end
end