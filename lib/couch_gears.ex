defmodule CouchGears do

  def start(env) when is_atom(env) do
    :application.start(:dynamo)
    :application.set_env(:dynamo, :env, env)

    :application.start(:couch_gears)
  end
end
