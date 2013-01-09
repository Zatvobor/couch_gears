defmodule CouchGears.Case do
  @moduledoc """
  A convenience macros for testing gear application and routes.

  ## Examples

    defmodule ApplicationRouterTest do
      use ExUnit.Case, async: true
      use CouchGears.Case

      Code.require_file "app/routers/application_router.ex"
      @app ApplicationRouter


      test "returns not_found" do
        assert get(path: "u/n/k/n/o/w/n").status == 404
      end

      test "returns body as json" do
        conn = get(path: "/", headers: [{"Content-Type", "application/json"}])

        assert conn.status == 200
        assert conn.resp_headers("Content-Type") == "application/json"
        assert conn.resp_body == "{\"ok\":\"Hello World\"}"
      end
    end

  """

  @doc false
  defmacro __using__(_) do
    quote do
      Code.prepend_path File.expand_path("../../../deps/couchdb/src/couchdb", unquote(__FILE__))
      Code.prepend_path File.expand_path("../../../deps/couchdb/src/mochiweb", unquote(__FILE__))
      Code.prepend_path File.expand_path("../../../deps/couchdb/src/ejson", unquote(__FILE__))

      import unquote(__MODULE__)

      CouchGears.env("test")
    end
  end

  @doc false
  defmacro get(params) do
    do_method :GET, params
  end

  @doc false
  defmacro post(params) do
    do_method :POST, params
  end

  @doc false
  defmacro put(params) do
    do_method :PUT, params
  end

  # @doc false
  defmacro delete(params) do
    do_method :DELETE, params
  end

  @doc false
  def do_method(method, params) do
    quote do: unquote(__MODULE__).process @app, unquote(method), unquote(params)
  end


  @doc """
  So in case you want to dispatch request to different gear application.
  This function may be useful.
  """
  def process(app, method, params) do
    conn = CouchGears.Mochiweb.HTTP.Test.new(params[:path], method, params)
    conn = app.service(conn)

    if not is_tuple(conn) or not function_exported?(elem(conn, 0), :state, 1) do
      raise "#{inspect app}.service did not return a connection, got #{inspect conn}"
    end

    if conn.state == :unset do
      raise "#{inspect app}.service returned a connection that did not respond yet"
    end
    conn
  end
end