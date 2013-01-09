defmodule CouchGears.Router do
  @moduledoc """
  This is a main module for gear router.
  Actually, it's a simple wrapper around `Dynamo.Router` module.

  Check the `Dynamo.Router` module for examples and documentation.

  """

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      use Dynamo.Router
    end
  end

end