Code.require_file "../../../test_helper.exs", __FILE__

defmodule CouchGears.Mochiweb.HTTP.TestTest do
  use ExUnit.Case, async: true

  @subject CouchGears.Mochiweb.HTTP.Test


  test "returns under test connection" do
    conn = @subject.new("/a/b/c", :GET, headers: [{"Content-Type", "application/json"}])

    assert is_record(conn, CouchGears.Mochiweb.HTTP)
    assert conn.httpd.mochi_req == {:mochiweb_request,nil,:GET,'/a/b/c',{1,1},{1,{'content-type',{"Content-Type",'application/json'},nil,nil}}}
    assert conn.httpd.method == :GET
    assert conn.httpd.path_parts == ["under_test","_gears","a","b","c"]
  end
end