defmodule CouchGears do
  @moduledoc """
  CouchGears tries to load each application from `apps/*` directory.
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


  # Helpers

  @doc """
  Gets current version.
  """
  def version, do: "0.5.0.dev"

  @doc """
  Gets runtime environment.
  """
  def env do
    case :application.get_env(:couch_gears, :env) do
      :undefined -> System.get_env("MIX_ENV") || "dev"
      {:ok, env} -> env
    end
  end

  @doc false
  def env(name), do: :application.set_env(:couch_gears, :env, name)

  @doc """
  Gets CouchGears absolute path
  """
  def root_path do
    {:ok, root_path} = :application.get_env(:couch_gears, :root_path)
    root_path
  end

  @doc false
  def root_path(value), do: :application.set_env(:couch_gears, :root_path, value)

  @doc """
  Gets all initialized applications. Check the `CouchGears.Httpd.DbHandlers` module
  for example.
  """
  def gears do
    {:ok, apps} = :application.get_env(:couch_gears, :gears)
    apps
  end

  @doc false
  def gears(apps), do: :application.set_env(:couch_gears, :gears, apps)
end