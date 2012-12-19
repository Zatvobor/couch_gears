Code.require_file "../../../test_helper.exs", __FILE__

defmodule CouchGears.Filters.OnlyRequestTypeJsonTest do
  use ExUnit.Case, async: true
  use CouchGears.Case


  defmodule Subject do
    use CouchGears.Router

    filter CouchGears.Filters.OnlyRequestTypeJSON

    get "/", do: conn.resp_body("ok")
  end

  @app Subject


  test "tries to request a filtered resource" do
    assert_raise FunctionClauseError, fn -> get(path: "/") end
  end

  test "returns a requested resource" do
    conn  = get(path: "/", headers: [{"Content-Type", "application/json"}])

    assert conn.status == 200
    assert conn.resp_body == "ok"
  end

end