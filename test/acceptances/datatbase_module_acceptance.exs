Code.require_file "../../acceptance_helper.exs", __FILE__

defmodule DatabaseModuleAcceptance do
  use ExUnit.Case, async: true

  use CouchGears.Database.Fixtures



  test "tries to find a undefined document" do
    assert find_raw("missing_db", "missing_doc") == :no_db_file
    assert find_raw(@db, "missing_doc") == :missing
  end

  test "returns a raw document" do
    assert find_raw(@db, "x") == @raw_x_doc
  end

  test "returns a document as a hash dict" do
    assert find(@db, "x").to_list == @x_doc
  end

end