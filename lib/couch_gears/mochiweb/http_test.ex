defmodule CouchGears.Mochiweb.HTTP.Test do
  @moduledoc false

  defrecord Httpd, Record.extract(:httpd, from: "couch_db.hrl")


  @doc false
  def new(path, method, opts // []) do
    new(fake_httpd(fake_request(path, method, opts)))
  end

  @doc false
  def new(httpd) do
    CouchGears.Mochiweb.HTTP.new(:uder_test, httpd, :under_test)
  end



  defp fake_request(path, method, opts) do
    headers = opts[:headers] || [{"Accept", "*/*"}]
    :mochiweb_request.new(nil, method, binary_to_list(path), {1, 1}, :mochiweb_headers.make(headers))
  end

  defp fake_httpd(mochi_req) do

    # HttpReq = #httpd{
    #     mochi_req = MochiReq,
    #     peer = MochiReq:get(peer),
    #     method = Method,
    #     requested_path_parts =
    #         [?l2b(unquote(Part)) || Part <- string:tokens(RequestedPath, "/")],
    #     path_parts = [?l2b(unquote(Part)) || Part <- string:tokens(Path, "/")],
    #     db_url_handlers = DbUrlHandlers,
    #     design_url_handlers = DesignUrlHandlers,
    #     default_fun = DefaultFun,
    #     url_handlers = UrlHandlers,
    #     user_ctx = erlang:erase(pre_rewrite_user_ctx)
    # },

    [_|path_parts] = String.split(list_to_binary(mochi_req.get(:raw_path)), "/")
    path_parts = Enum.filter path_parts, &1 != ""
    path_parts = ["under_test", "_gears" | path_parts]

    Httpd.new(
      mochi_req: mochi_req,
      method: mochi_req.get(:method),
      path_parts: path_parts
    )
  end
end