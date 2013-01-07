defmodule CouchGears do
  @moduledoc """
  This is a main module for every gear application.
  Actually, it's a simple wrapper around `Dynamo` module.

  Check the `Dynamo` module for examples and documentation.

  Developers can use module functions to configure and receive
  access to execution environment.
  """


  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      use Dynamo
      import unquote(__MODULE__)
    end
  end

  @doc false
  defmacro environment(name, contents) when is_binary(name) do
    if CouchGears.env == name, do: contents
  end

  @doc false
  defmacro environment(reg, contents) do
    quote do: if Regex.match?(unquote(reg), CouchGears.env), do: unquote(contents)
  end


  @doc false
  def version, do: "0.5.0.dev"

  @doc false
  def env do
    case :application.get_env(:couch_gears, :env) do
      :undefined -> System.get_env("MIX_ENV") || "dev"
      {:ok, env} -> env
    end
  end

  @doc false
  def env(name), do: :application.set_env(:couch_gears, :env, name)

  @doc false
  def root_path do
    {:ok, root_path} = :application.get_env(:couch_gears, :root_path)
    root_path
  end

  @doc false
  def root_path(value), do: :application.set_env(:couch_gears, :root_path, value)

  @doc false
  def gears do
    {:ok, apps} = :application.get_env(:couch_gears, :gears)
    apps
  end

  @doc false
  def gears(apps), do: :application.set_env(:couch_gears, :gears, apps)
end
