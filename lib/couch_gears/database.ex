defmodule CouchGears.Database do
  @moduledoc """
  This module provides CRUD functions for managing either databases or documents.
  The main important thing is a `database` module designed to be a 'instance' for certain DB (see examples below).

  ## Examples:

      db = CouchGears.Database.open("db")
      db.find("x")
      db.close()

  Is an equivalent to:

      CouchGears.Database.find("db", "x")

  also you can use a `database` module from pure Erlang environment:

      Db = 'Elixir-CouchGears-Database':open(<<"db">>),
      Db:find(<<"x">>),
      DB:close().

      'Elixir-CouchGears-Database':find(<<"db">>, <<"x">>).
  """

  alias CouchGears.Database.Helpers, as: Helpers
  alias CouchGears.Records, as: Records


  Code.prepend_path("include")
  defrecord Db, Record.extract(:db, from: "couch_db.hrl")

  defrecordp :database, [:raw_db, :db]


  @doc """
  Gets associated `db` record. Check a `include/couch_db.hrl` for details.
  """
  def db(database(db: db)), do: db

  @doc """
  Gets associated raw `db` record which has been returned from `couch_db:open_int/2`.
  """
  def raw_db(database(raw_db: raw_db)), do: raw_db

  @doc """
  Opens a `db` and returns a `database` instance or `:no_db_file` atom in case it doesn't exist.
  """
  def open(db_name) do
    db = do_open(db_name)

    unless db == :no_db_file do
      db = database(raw_db: db, db: Db.new(db))
    end

    db
  end

  @doc """
  Opens a `db` and returns a `database` instance or exception in case it doesn't exist.
  """
  def open!(db_name) do
    db = open(db_name)

    if db == :no_db_file do
      raise "No db file"
    end

    db
  end

  @doc """
  Closes associated `db`.
  """
  def close(database(raw_db: raw_db)) do
    :couch_db.close(raw_db)
    database()
  end

  @doc """
  Creates a `db`.
  """
  def create_db(db_name, opts // []) do
    :couch_server.create(db_name, opts)
  end

  @doc """
  Deletes a `db`.
  """
  def delete_db(db_name, opts // []) do
    :couch_server.delete(db_name, opts)
  end

  @doc """
  Returns a `document` as a raw `list` or either `:no_db_file`/`:missing` atom.
  """
  def find_raw(_doc_id, :no_db_file), do: :no_db_file

  def find_raw(doc_id, db) when is_record(db, CouchGears.Database) do
    find_raw(doc_id, [], db)
  end

  def find_raw(db_name, doc_id), do: find_raw(doc_id, [], open(db_name))

  @doc """
  Returns a `document` as a raw `list` or either `:no_db_file`/`:missing` atom.
  An `opts` is a convenience for filtering

  ## Options

  * `except:` - The list of fields which should be cut from a document body

  * `only:`   - The strict list of fields which should have a returned document

  ## Examples

    Database.find_raw("db", "doc_id", [only: ["_id"]])
    # => [{"_id", "doc_id"}]

    Database.find_raw("db", "doc_id", [except: ["_id"]])
    # => [{"_rev", "1-41f7a51b6f7002e9a41ad4fc466838e4"}]

  """
  def find_raw(_doc_id, _opts, :no_db_file), do: :no_db_file

  def find_raw(doc_id, opts, db) when is_record(db, CouchGears.Database) do
    { _, raw_doc } = do_find(doc_id, db)
    do_filter(raw_doc, opts)
  end

  def find_raw(db_name, doc_id, opts), do: find_raw(doc_id, opts, open(db_name))

  @doc """
  Returns a `document` as a `HashDict` or either `:no_db_file`/`:missing` atom.
  """
  def find(doc_id, db) when is_record(db, CouchGears.Database), do: find(doc_id, [], db)

  def find(doc_id, db_name), do: find(doc_id, db_name, [])

  @doc """
  Returns a `document` as a raw `list` or either `:no_db_file`/`:missing` atom.
  An `opts` is a convenience for filtering

  ## Options

  * `except:` - The list of fields which should be cut from a document body

  * `only:`   - The strict list of fields which should have a returned document

  """
  def find(doc_id, opts, db) when is_record(db, CouchGears.Database) do
    do_doc find_raw(doc_id, opts, db)
  end

  def find(doc_id, db_name, opts) do
    do_doc find_raw(doc_id, db_name, opts)
  end

  @doc """
  Returns a `document` as a `HashDict` or either `:no_db_file`/`:missing` atom.
  """
  def find_with_rev(_doc_id, _rev, :no_db_file), do: :no_db_file

  def find_with_rev(doc_id, rev, database(raw_db: raw_db)) do
    case :couch_db.open_doc_revs(raw_db, doc_id, make_rev(rev), []) do
      {:ok, [{:ok, doc}]} ->
        {body} = :couch_doc.to_json_obj(doc, [])
        HashDict.new(body, Helpers.from_list_to_hash_dict_transform)
      _ ->
        :missing
    end
  end

  def find_with_rev(db_name, doc_id, rev), do: find_with_rev(doc_id, rev, open(db_name))

  @doc """
  Creates a `document` and return a `document` or either `:conflict`/`:no_db_file` atom.
  """
  def create_doc(_doc, :no_db_file), do: :no_db_file

  def create_doc(db_name, raw_doc) when is_list(raw_doc) do
    create_doc(raw_doc, open(db_name))
  end

  def create_doc(db_name, hash_doc) when is_record(hash_doc, HashDict) do
    create_doc(db_name, Helpers.from_hash_dict_to_list(hash_doc))
  end

  def create_doc(hash_doc, db) when is_record(hash_doc, HashDict) and is_record(db, CouchGears.Database) do
    raw_doc = create_doc(Helpers.from_hash_dict_to_list(hash_doc), db)
    HashDict.new(raw_doc, Helpers.from_list_to_hash_dict_transform)
  end

  # it'd be a much better (inside)
  def create_doc(raw_doc, db) when is_list(raw_doc) and is_record(db, CouchGears.Database) do
    update(raw_doc, db)
    find_raw(raw_doc, db)
  end

  @doc """
  Updates a particular `document` and return a `rev` string or either `:conflict`/`:no_db_file` atom.
  """
  def update(_doc, :no_db_file), do: :no_db_file

  def update(raw_doc, database(raw_db: raw_db)) when is_list(raw_doc) do
    json_doc   = :couch_doc.from_json_obj({raw_doc})
    {:ok, rev} = :couch_db.update_doc(raw_db, json_doc, [])
    rev
  end

  def update(hash_doc, db) when is_record(hash_doc, HashDict) and is_record(db, CouchGears.Database) do
    raw_doc = Helpers.from_hash_dict_to_list(hash_doc)
    update(raw_doc, db)
  end

  def update(db_name, raw_doc) when is_list(raw_doc), do: update(raw_doc, open(db_name))

  def update(db_name, hash_doc) when is_record(hash_doc, HashDict), do: update(hash_doc, open(db_name))

  @doc """
  Enumerates through particular `db` and pass arguments such a `FullDocInfo` record,
  something like `reds` and execution accumulator as a second argument to `callback` function.
  Check a `couch_db:enum_docs/4` function usage example for more information.
  """
  def enum_docs(db, callback, opts) when is_record(db, CouchGears.Database) and is_function(callback, 3) do
    function = fn(raw_full_doc_info, reds, acc) ->
      callback.(Records.FullDocInfo.new(raw_full_doc_info), reds, acc)
    end
    :couch_db.enum_docs(db.raw_db, function, [], opts || [])
  end

  def enum_docs(db_name, callback, opts), do: enum_docs(open(db_name), callback, opts)
  def enum_docs(db_name, callback), do: enum_docs(db_name, callback, [])



  # Internal stuff

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

  defp do_doc(missing) when is_atom(missing), do: missing

  defp do_doc(raw_doc) when is_list(raw_doc) do
    HashDict.new(raw_doc, Helpers.from_list_to_hash_dict_transform)
  end

  defp do_filter(missing, _opts) when is_atom(missing), do: missing
  defp do_filter(raw_doc, []), do: raw_doc

  defp do_filter(raw_doc, opts) do
    fun = case opts do
      [except: fields] ->
        fn({k,_}) -> !List.member?(fields, k) end
      [only: fields] ->
        fn({k,_}) -> List.member?(fields, k) end
    end
    Enum.filter(raw_doc, fun)
  end

  defp make_rev(rev), do: [:couch_doc.parse_rev(rev)]
end