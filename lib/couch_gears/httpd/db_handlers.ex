defmodule CouchGears.Httpd.DbHandlers do

  @doc false
  def handle_db_gears_req(httpd, _db) do
    CouchGears.Mochiweb.Handler.call(CouchGearApplication, httpd, :undefined)
  end

end