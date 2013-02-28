defmodule CouchGears.Database.Metadata do
  @moduledoc """
  This module provides ability to get a `CouchGears.Records` related entities.
  """

  alias CouchGears.Records, as: Records


  @doc false
  def to_db(name) do
    fun = fn([_,_]) ->
      {_, r} = :couch_db.open(name, [])
      unless r == :no_db_file do
        r = Records.Db.new(r)

        r = r.update(header: Records.DbHeader.new(r.header))

        r = r.update(fulldocinfo_by_id_btree: Records.BTree.new(r.fulldocinfo_by_id_btree))
        r = r.update(docinfo_by_seq_btree:    Records.BTree.new(r.docinfo_by_seq_btree))
        r = r.update(local_docs_btree:        Records.BTree.new(r.local_docs_btree))

        r
      end
      r
    end
    touch_db(name, nil, fun)
  end

  @doc false
  def to_doc(db_name, id) do
    fun = fn([r, id]) ->
      {_, r} = :couch_db.open_doc(r, id, [])
      unless r == :missing do
        r = Records.Doc.new(r)
        r.update(atts: Enum.map r.atts, fn(i) -> Records.Att.new(i) end)
      end
      r
    end
    touch_db(db_name, id, fun)
  end

  @doc false
  def to_doc_info(db_name, id) do
    fun = fn([r, id]) ->
      case :couch_db.get_doc_info(r, id) do
        { :ok, r } ->
          r = Records.DocInfo.new(r)
          r.update(revs: Enum.map r.revs, fn(i) -> Records.RevInfo.new(i) end)
        missing ->
          missing
      end
    end
    touch_db(db_name, id, fun)
  end


  defp touch_db(name, id, fun) do
    {_, r} = :couch_db.open(name, [])
    unless r == :no_db_file, do: r = fun.([r, id])
    r
  end
end