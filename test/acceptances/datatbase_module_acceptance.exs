Code.require_file "../../acceptance_helper.exs", __FILE__

defmodule DatabaseModuleAcceptance do
  use ExUnit.Case, async: true

  import CouchGears.Database


  # Data fixtures
  @x [{"_id","x"},{"_rev","1-967a00dff5e02add41819138abb3284d"}]
  @db "db"



  test "tries to find undefined document" do
    assert find("missing_db", "missing_doc") == :no_db_file
    assert find(@db, "missing_doc") == :missing
  end

  test "loads a document as a module function" do
    assert find(@db, "x") == @x
  end

end