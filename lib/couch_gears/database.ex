defmodule CouchGears.Database do
  @moduledoc """

  ## Code snippets:

  1. from pure Erlang:

      Db = 'Elixir-CouchGears-Database':open(<<"db">>).
      Db:find(<<"x">>).

      'Elixir-CouchGears-Database':find(<<"db">>, <<"x">>).

  2. from pure Elixir:

      db = CouchGears.Database.open("db")
      db.find("x")

      CouchGears.Database.find("db", "x")
  """

  Code.prepend_path("include")
  defrecord Db, Record.extract(:db, from: "couch_db.hrl")

  defrecordp :database, [:raw_db, :db]


  # Instance functions

  @doc false
  def db(database(raw_db: raw_db)) do
    database(raw_db: raw_db, db: Db.new(raw_db))
  end


  # Module functions

  @doc false
  def open(name) do
    db = do_open(name)

    unless db == :no_db_file do
      db = database(raw_db: db)
    end
    db
  end


  @doc false
  def open!(name) do
    db = open(name)

    if db == :no_db_file do
      raise "No db file"
    end
    db
  end


  @doc false
  def find_raw(_db, :no_db_file), do: :no_db_file

  @doc false
  def find_raw(ddoc, database(raw_db: _r) = db) do
    { _, document } = do_find(ddoc, db)
    document
  end

  @doc false
  def find_raw(db, ddoc), do: find_raw(ddoc, open(db))

  @doc false
  def find(a, b) do
    doc = find_raw(a, b)

    unless doc == :no_db_file do
      doc = HashDict.new(doc)
    end
    doc
  end



  defp do_open(name) do
    case :couch_db.open_int(to_binary(name), []) do
      { :not_found, :no_db_file } -> :no_db_file
      { _, db } -> db
    end
  end

  defp do_find(ddoc, database(raw_db: raw_db)) do
    case :couch_db.open_doc(raw_db, ddoc) do
      {:ok, doc} ->
        {body} = :couch_doc.to_json_obj(doc, [])
        # parse_to_record(body, db_name, id)
        {:ok, body }
      _ ->
        {:not_found, :missing}
    end
  end
end