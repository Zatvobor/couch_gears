Code.require_file "../../acceptance_helper.exs", __FILE__

defmodule Database.MetadataAcceptance do
  use ExUnit.Case, async: false

  import CouchGears.Database.Metadata
  alias CouchGears.Records, as: Records


  test "tries get a misisng Db record" do
    db = to_db("missing")
    assert db == :no_db_file
  end

  test "returns a Db record" do
    db = to_db("fixture")
    assert is_record(db, Records.Db)
  end

  test "tries get a Doc record in case of missing db" do
    doc = to_doc("missing", "missing")
    assert doc == :no_db_file
  end

  test "tries get a missing Doc record" do
    doc = to_doc("fixture", "missing")
    assert doc == :missing
  end

  test "returns a Doc record" do
    doc = to_doc("fixture", "x")
    assert is_record(doc, Records.Doc)
  end

  test "tries get a DocInfo record in case of missing db" do
    doc_info = to_doc_info("missing", "missing")
    assert doc_info == :no_db_file
  end

  test "tries get a missing DocInfo record" do
    doc_info = to_doc_info("fixture", "missing")
    assert doc_info == :not_found
  end

  test "returns a DocInfo record" do
    doc_info = to_doc_info("fixture", "x")
    assert is_record(doc_info, Records.DocInfo)
  end

end