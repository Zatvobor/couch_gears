Code.require_file "../../acceptance_helper.exs", __FILE__

defmodule Database.MetadataAcceptance do
  use ExUnit.Case, async: false

  import CouchGears.Database.Metadata
  alias CouchGears.Records, as: Records


  test "tries to_db for misisng db" do
    db = to_db("missing")
    assert db == :no_db_file
  end

  test "returns a db record" do
    db = to_db("fixture")
    assert is_record(db, Records.Db)
  end

end