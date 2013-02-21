defmodule CouchGears.Records do
  @moduledoc """
  This module provides a spatial convenience between pure CouchDB records and natural Elixir's records.
  """

  Code.prepend_path("include")


  defrecord Httpd, Record.extract(:httpd, from: "couch_db.hrl")
  defrecord FullDocInfo, Record.extract(:full_doc_info, from: "couch_db.hrl")
end