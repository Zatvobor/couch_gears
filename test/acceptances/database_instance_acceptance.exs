Code.require_file "../../acceptance_helper.exs", __FILE__

defmodule DatabaseInstanceAcceptance do
  use ExUnit.Case, async: true

  use CouchGears.Database.Fixtures



  test "tries to open a missing db" do
    missing_db = open("missing_db")
    assert missing_db == :no_db_file
  end

  test "opens a db" do
    db = open(@db)
    assert is_record(db, CouchGears.Database)
  end

  test "returns a raw document" do
    db = open(@db)
    assert db.find_raw("x") == @raw_x_doc
  end

  test "returns a document as a hash dict" do
    db = open(@db)
    assert db.find("x").to_list == @x_doc
  end
end