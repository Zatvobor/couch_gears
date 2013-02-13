Code.require_file "../../test_helper.exs", __FILE__

defmodule ApplicationRouterTest do
  use ExUnit.Case, async: true
  use CouchGears.Case


  defmodule SimpleApp do
    use CouchGears.Router

    get "/" do
      conn.resp_body("ok").assign :value, :root
    end

    get "/json" do
      conn.resp_body("{\"ok\":\"Hello World\"}")
    end
  end

  @app SimpleApp


  test "returns not_found" do

    # conn = get(path: "u/n/k/n/o/w/n")
    # assert conn.status == 404
    # refute conn.already_sent?

    assert_raise Dynamo.NotFoundError, fn ->
      get(path: "u/n/k/n/o/w/n")
    end
  end

  test "dispatches on root" do
    conn = get(path: "/")

    assert conn.status == 200
    assert conn.already_sent?
    assert conn.resp_body == "ok"
    assert conn.assigns[:value] == :root
  end

  test "returns json body" do
    conn = get(path: "/json")

    assert conn.status == 200
    assert conn.resp_body == "{\"ok\":\"Hello World\"}"
  end

end