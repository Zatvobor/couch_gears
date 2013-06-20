defmodule CouchGears do
  @moduledoc """
  A convenience for customizing a Couch DB API as you need
  Check the `README.md`
  """

  @doc """
  Gets current version.
  """
  def version, do: "0.7"

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
  Gets all initialized applications
  for example.
  """
  def gears do
    {:ok, apps} = :application.get_env(:couch_gears, :gears)
    apps
  end

  @doc false
  def gears(apps), do: :application.set_env(:couch_gears, :gears, apps)
end