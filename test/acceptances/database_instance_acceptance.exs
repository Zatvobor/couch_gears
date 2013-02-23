Code.require_file "../../acceptance_helper.exs", __FILE__

defmodule DatabaseInstanceAcceptance do
  use ExUnit.Case, async: false

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

  test "returns a filtered document (except: ['number', 'string'])" do
    { doc_id, doc_body } = { "except", [{"_id","except"}, {"number",1}, {"string","s"}, {"boolean",true}] }
    create_fixture doc_body

    doc = DB.open(@fixture_db).find_raw(doc_id, [except: ["number", "string"]])

    assert Enum.count(doc) == 3
    assert doc["_id"]      == doc_id
    assert doc["boolean"]
  end

  test "returns a filtered document (only: ['number', 'string'])" do
    { doc_id, doc_body }   = { "only", [{"_id","only"}, {"number",1}, {"string","s"}, {"boolean",true}] }
    create_fixture doc_body

    doc = DB.open(@fixture_db).find_raw(doc_id, [only: ["number", "string"]])
    assert doc == [{"number", 1}, {"string", "s"}]
  end


  test "returns a document as a hash dict" do
    db = DB.open(@fixture_db)
    doc = db.find(@doc_x)

    assert doc["_id"] == @doc_x
  end

  test "creates a document w/ specific id" do
    rev = DB.open(@fixture_db).create_doc([{"_id", "strict"},{"boolean", false}])
    doc = DB.open(@fixture_db).find_raw("strict")

    assert Enum.count(doc) == 3
    assert doc["_id"] == "strict"
    assert doc["_rev"] == rev
  end

  test "creates a document w/ out id" do
    rev = DB.open(@fixture_db).create_doc([{"boolean", false}])
    {1, _} = :couch_doc.parse_rev(rev)
  end

  test "updates a document as a hash dict" do
    db = DB.open(@fixture_db)
    doc = db.find(@doc_x)

    doc = HashDict.put(doc, "boolean", true)
    prev_rev = doc["_rev"]
    new_rev  = db.update(doc)

    db.close()
    db = DB.open(@fixture_db)

    doc = db.find(@doc_x)

    assert doc["boolean"]
    refute prev_rev == new_rev
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