Code.require_file "../../test_helper.exs", __FILE__

defmodule CouchGears.Mochiweb.Connection.TestTest do
  use ExUnit.Case, async: true

  @subject CouchGears.Mochiweb.Connection.Test


  test "returns under test connection" do
    conn = @subject.new("/a/b/c", :GET, headers: [{"Content-Type", "application/json"}])

    assert is_record(conn, CouchGears.Mochiweb.Connection)
    assert conn.httpd.method == :GET
    assert conn.httpd.path_parts == ["under_test","_gears","a","b","c"]
  end
end