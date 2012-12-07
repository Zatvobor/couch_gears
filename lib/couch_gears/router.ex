defmodule CouchGears.Router do

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      use Dynamo.Router
    end
  end

end