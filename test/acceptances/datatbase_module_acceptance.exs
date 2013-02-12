Code.require_file "../../acceptance_helper.exs", __FILE__

defmodule DatabaseModuleAcceptance do
  use ExUnit.Case, async: true

  @fixture_db "fixture"
  use CouchGears.Database.Fixtures

  @doc_x "x"
  @doc_x_body [{"_id","x"}, {"number", 1}]

  create_fixture @doc_x_body


  test "tries to find a undefined document" do
    assert DB.find_raw("missing_db", "missing_doc") == :no_db_file
    assert DB.find_raw(@fixture_db, "missing_doc") == :missing
  end

  test "returns a raw document" do
    doc_x = DB.find_raw(@fixture_db, @doc_x)
    assert  doc_x["_id"] == @doc_x
  end

  test "returns a document as a hash dict" do
    doc_x = DB.find(@fixture_db, @doc_x)
    assert doc_x["_id"] == @doc_x
  end

end