defmodule CouchGears.Records do
  @moduledoc """
  This module provides a spatial convenience between pure CouchDB records and natural Elixir's records.
  """

  Code.prepend_path("include")


  @doc """
  A mapping for `#httpd` record which represents a HTTP request environment
  """
  defrecord Httpd, Record.extract(:httpd, from: "couch_db.hrl")
end