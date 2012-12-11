defmodule CouchGears do

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      use Dynamo
    end
  end

end
