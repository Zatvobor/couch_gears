Code.require_file "../../acceptance_helper.exs", __FILE__

defmodule DatabaseInstanceAcceptance do
  use ExUnit.Case, async: true

  import CouchGears.Database


  # Data fixtures
  @x [{"_id","x"},{"_rev","1-967a00dff5e02add41819138abb3284d"}]
  @db "db"



  test "tries to open a missing db" do
    assert open("missing_db") == :no_db_file
  end

  test "opens a db" do
    db = open(@db)
    assert is_record(db, CouchGears.Database)
  end

  test "loads a document as a instance function" do
    db = open(@db)
    assert db.find("x") == @x
  end
end