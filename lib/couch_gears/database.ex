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

  alias CouchGears.Database.Helpers, as: Helpers


  Code.prepend_path("include")
  defrecord Db, Record.extract(:db, from: "couch_db.hrl")

  defrecordp :database, [:raw_db, :db]


  @doc false
  def db(database(db: db)), do: db

  @doc false
  def raw_db(database(raw_db: raw_db)), do: raw_db

  @doc false
  def open(name) do
    db = do_open(name)

    unless db == :no_db_file do
      db = database(raw_db: db, db: Db.new(db))
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
  def close(database(raw_db: raw_db)) do
    :couch_db.close(raw_db)
    database()
  end

  @doc false
  def create_db(name) do
    :couch_server.create(name, [])
  end

  @doc false
  def delete_db(name) do
    :couch_server.delete(name, [])
  end

  @doc false
  def find_raw(_db, :no_db_file), do: :no_db_file

  @doc false
  def find_raw(doc_id, db) when is_record(db, CouchGears.Database) do
    { _, document } = do_find(doc_id, db)
    document
  end

  @doc false
  def find_raw(db, doc_id), do: find_raw(doc_id, open(db))

  @doc false
  def find(a, b) do
    doc = find_raw(a, b)

    unless doc == :no_db_file || doc == :missing do
      doc = HashDict.new(doc, Helpers.from_list_to_hash_dict_transform)
    end

    doc
  end

  @doc false
  def find_with_rev(doc_id, rev, database(raw_db: raw_db)) do
    case :couch_db.open_doc_revs(raw_db, doc_id, make_rev(rev), []) do
      {:ok, [{:ok, doc}]} ->
        {body} = :couch_doc.to_json_obj(doc, [])

        {:ok, body}
      _ ->
        {:not_found, :missing}
    end
  end

  @doc false
  def find_with_rev(db, doc_id, rev) do
    { _, document } = find_with_rev(doc_id, rev, open(db))
    document
  end

  @doc false
  def update(raw_doc, database(raw_db: raw_db)) when is_list(raw_doc) do
    json_doc   = :couch_doc.from_json_obj({raw_doc})
    {:ok, rev} = :couch_db.update_doc(raw_db, json_doc, [])
    rev
  end

  @doc false
  def update(hash_doc, db) when is_record(hash_doc, HashDict) and is_record(db, CouchGears.Database) do
    raw_doc = Helpers.from_hash_dict_to_list(hash_doc)
    update(raw_doc, db)
  end

  @doc false
  def update(db, raw_doc) when is_list(raw_doc), do: update(raw_doc, open(db))

  @doc false
  def update(db, hash_doc) when is_record(hash_doc, HashDict), do: update(hash_doc, open(db))

  @doc false
  def create_doc(db, raw_doc) when is_list(raw_doc) do
    create_doc(raw_doc, open(db))
  end

  @doc false
  def create_doc(db, hash_doc) when is_record(hash_doc, HashDict) do
    create_doc(db, Helpers.from_hash_dict_to_list(hash_doc))
  end

  @doc false
  def create_doc(hash_doc, db) when is_record(hash_doc, HashDict) and is_record(db, CouchGears.Database) do
    raw_doc = create_doc(Helpers.from_hash_dict_to_list(hash_doc), db)
    HashDict.new(raw_doc, Helpers.from_list_to_hash_dict_transform)
  end

  @doc false
  def create_doc(raw_doc, db) when is_list(raw_doc) and is_record(db, CouchGears.Database) do
    update(raw_doc, db)
    find_raw(raw_doc, db)
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
        {:ok, body }
      _ ->
        {:not_found, :missing}
    end
  end

  defp make_rev(rev), do: [:couch_doc.parse_rev(rev)]
end