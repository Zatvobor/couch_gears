defmodule CouchGears.Logger do
  @moduledoc false

  @doc false
  def debug(message, args // []) do
    if :couch_log.debug_on(), do: :couch_log.debug(binary_to_list(message), args)
  end

  @doc false
  def info(message, args // []) do
    if :couch_log.info_on(), do: :couch_log.info(binary_to_list(message), args)
  end

  @doc false
  def error(message, args // []) do
    if :couch_log.error_on(), do: :couch_log.error(binary_to_list(message), args)
  end
end