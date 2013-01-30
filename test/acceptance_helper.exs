# Cleanups db

# Setups fixtures
defmodule CouchGears.Database.Fixtures do

  defmacro __using__(_) do
    quote do
      @db "db"

      @raw_x_doc [{"_id","x"},{"_rev","1-967a00dff5e02add41819138abb3284d"}]
      @x_doc [{"_id","x"},{"_rev","1-967a00dff5e02add41819138abb3284d"}]

      import unquote(CouchGears.Database)
    end
  end

end

ExUnit.start