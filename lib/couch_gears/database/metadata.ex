defmodule CouchGears.Database.Metadata do
  @moduledoc """
  This module provides ability to get a `CouchGears.Records` related entities.
  """

  alias CouchGears.Records, as: Records


  @doc false
  def to_db(name) do
    {_, r} = :couch_db.open(name, [])
    unless r == :no_db_file, do: r = Records.Db.new(r)
    r
  end

  @doc false
  def to_doc(db_name, id) do
    {_, r} = :couch_db.open(db_name, [])
    unless r == :no_db_file do
      {_, r} = :couch_db.open_doc(r, id, [])
      unless r == :missing, do: r = Records.Doc.new(r)
    end
    r
  end

  @doc false
  def to_doc_info(db_name, id) do
    {_, r} = :couch_db.open(db_name, [])
    unless r == :no_db_file do
      r = :couch_db.get_doc_info(r, id)
      unless r == :not_found, do: r = Records.DocInfo.new(r)
    end
    r
  end
end