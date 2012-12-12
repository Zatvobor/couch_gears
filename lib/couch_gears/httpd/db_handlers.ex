defmodule CouchGears.Httpd.DbHandlers do

  @doc false
  def handle_db_gears_req(httpd, db) do
    db_name = :erlang.element(15, db)
    {:ok, apps} = :application.get_env(:couch_gears, :gears)
    # It doesn't work for one more enabled application :)
    List.last Enum.map apps, fn(app) ->
      if app.config[:gear][:known_db] == :all do
        CouchGears.Mochiweb.Handler.call(app, httpd, db_name)
      else
        raise "Bad value for the :known_db option (enabled only :all)"
      end
    end
  end

end