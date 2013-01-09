defmodule CouchGears.Httpd.DbHandlers do
  @moduledoc false

  @doc false
  def handle_db_gears_req(httpd, db) do
    db_name = :erlang.element(15, db)

    List.last Enum.map CouchGears.gears, fn(app) ->
      if app.config[:gear][:known_db] == :all do
        CouchGears.Mochiweb.Handler.call(app, httpd, db_name)
      else
        raise "Bad value for the :known_db option (enabled only :all)"
      end
    end
  end

end