defmodule CouchGears.Database.Fixtures do
  @moduledoc """
  A convenience for creating fixtured `db`s and `documents` which should be
  used for acceptance testing.
  """

  alias CouchGears.Database, as: DB
  alias CouchGears.Database.Helpers, as: DBHelp

  @doc false
  defmacro __using__(_) do
    quote do

      import unquote(CouchGears.Database.Fixtures)

      alias unquote(CouchGears.Database), as: DB
      alias unquote(CouchGears.Database.Helper), as: DBHelper

      if @fixture_db do
        DB.delete_db(@fixture_db)
        DB.create_db(@fixture_db)
      end

    end
  end

  @doc false
  defmacro create_fixture(document) do
    quote do: create_fixture(@fixture_db, unquote(document))
  end

  @doc false
  def create_fixture(db, document, to_hash_dict // true) do
    document = DB.create_doc(db, document)

    unless to_hash_dict do
      document = DBHelper.from_hash_dict_to_list(document)
    end

    document
  end

end

ExUnit.start