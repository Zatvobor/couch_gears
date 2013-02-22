defmodule CouchGears.Logger do
  @moduledoc """
  A module provides basic functions for logging. There are `debug`, `info`, `error` handlers
  which uses a `couch_log` module. So, all `couch_gears` log messages integrated with CouchDB logging.
  You could manage those log messages through generic CouchDB options.
  """

  @doc false
  def debug(message, args // []) do
    bump(:debug_on, :debug, message, args)
  end

  @doc false
  def info(message, args // []) do
    bump(:info_on, :info, message, args)
  end

  @doc false
  def error(message, args // []) do
    bump(:error_on, :error, message, args)
  end


  defp bump(check_fun, logger_fun, message, args) when is_function(check_fun) and is_function(logger_fun) do
    if check_fun.(), do: logger_fun.(message, args)
  end

  defp bump(check_fun, logger_fun, message, args) do
    bump(function(:couch_log, check_fun, 0), function(:couch_log, logger_fun, 2), binary_to_list(message), args)
  end
end