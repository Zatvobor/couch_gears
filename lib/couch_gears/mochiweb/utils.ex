defmodule CouchGears.Mochiweb.Utils do

  def get_resp_headers(resp_headers, resp_cookies) do
    Enum.reduce resp_cookies, Binary.Dict.to_list(resp_headers), fn({ key, value, opts }, acc) ->
      [{ "set-cookie", Dynamo.HTTP.Utils.cookie_header(key, value, opts) }|acc]
    end
  end

end