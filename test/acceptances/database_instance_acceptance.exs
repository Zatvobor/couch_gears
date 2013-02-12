Code.require_file "../../acceptance_helper.exs", __FILE__

defmodule DatabaseInstanceAcceptance do
  use ExUnit.Case, async: true

  @fixture_db "fixture"
  use CouchGears.Database.Fixtures

  @doc_x "x"
  @doc_x_body [{"_id","x"}, {"number", 1}]

  create_fixture @doc_x_body



  test "tries to open a missing db" do
    missing_db = DB.open("missing_db")
    assert missing_db == :no_db_file
  end

  test "opens a db" do
    db = DB.open(@fixture_db)
    assert is_record(db, CouchGears.Database)
  end

  test "closes a db" do
    db = DB.open(@fixture_db)
    db = db.close()

    refute db.raw_db
    refute db.db
  end

  test "returns a raw document" do
    db = DB.open(@fixture_db)
    doc = db.find_raw(@doc_x)

    assert doc["_id"] == @doc_x
  end

  test "returns a document as a hash dict" do
    db = DB.open(@fixture_db)
    doc = db.find(@doc_x)

    assert doc["_id"] == @doc_x
  end

  test "creates a db" do
    DB.create_db("x1")
    db = DB.open!("x1")

    assert is_record(db, CouchGears.Database)
  end

  test "removes a db" do
    DB.create_db("x2")
    DB.delete_db("x2")

    assert DB.open("x2") == :no_db_file
  end
end