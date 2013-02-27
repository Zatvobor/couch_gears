defmodule CouchGears.Database.Metadata do
  @moduledoc """
  This module provides ability to get a `CouchGears.Records` related entities.
  """


  alias CouchGears.Records, as: Records

  @doc false
  def to_db(name) do
    {_, db} = :couch_db.open_int(name, [])
    unless db ==  :no_db_file do
      db = Records.Db.new(db)
    end
    db
  end
end