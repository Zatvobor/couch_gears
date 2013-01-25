defmodule CouchGears.App do

  @moduledoc """
  A CouchGears tries to load each application from `apps/*` directory.
  Check the `CouchGears.Initializer` module for more details.

  Developers can use module functions to configure execution environment.

  ## Application (aka gear)

  This is a main module for gear application.
  Actually, it's a simple wrapper around `Dynamo` module.

  Check the `Dynamo` module for examples and documentation.

  """

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      use Dynamo
      import unquote(__MODULE__)
    end
  end

  @doc """
  Applies the environment specific block for application.

  ## Examples

    environment "dev" do
      config :dynamo, compile_on_demand: true, reload_modules: true
    end

  It sets `compile_on_demand: true, reload_modules: true` opts for application which
  started in the `dev` environment.

  """
  defmacro environment(name, contents) when is_binary(name) do
    if CouchGears.env == name, do: contents
  end

  defmacro environment(reg, contents) do
    quote do: if Regex.match?(unquote(reg), CouchGears.env), do: unquote(contents)
  end


   @doc false
   def normalize_config(config) when is_list(config) do
     unless config[:handlers] do
       config = [handlers: :undefined]
     else
       config = normalize_global_opts(config)
       config = normalize_dbs_opts(config)
     end
     config
   end

   @doc false
   def normalize_config(nil), do: normalize_config([])

   @doc false
   def normalize_config(app) do
     normalize_config(app.config[:gear])
   end


   defp normalize_global_opts(config) do
     global = config[:handlers][:global]

     global_should_be_false = fn(config) ->
       Keyword.put(config, :handlers, Keyword.put(config[:handlers], :global, false))
     end

     unless global, do: config = global_should_be_false.(config)
     unless is_boolean(global), do: config = global_should_be_false.(config)

     config
   end

   defp normalize_dbs_opts(config) do
     dbs = config[:handlers][:dbs]

     unless is_list(dbs) do
       unless dbs == :all do
         config = Keyword.put(config, :handlers, Keyword.put(config[:handlers], :dbs, []))
       end
     end

     if is_list(dbs) do
       dbs = Enum.map dbs, fn(db) ->
         cond do
           is_binary(db) -> binary_to_atom(db)
           is_atom(db)   -> db
         end
       end
       config = Keyword.put(config, :handlers, Keyword.put(config[:handlers], :dbs, dbs))
     end

     config
   end
end