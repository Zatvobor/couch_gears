[![Build Status](https://travis-ci.org/datahogs/couch_gears.png)](https://travis-ci.org/datahogs/couch_gears)

Couch Gears: A sexy convenience for customizing your Couch DB nodes as you need
-------------------------------------------------------------------------------

In short, `Couch Gears` is a spatial extension for [Apache CouchDB](https://github.com/apache/couchdb) based on [Dynamo](https://github.com/elixir-lang/dynamo) and tries to make the most out of this wonderful marriage of technologies.


### Status: under active development and  scoping (YOU're welcome!)
### Current version: `0.7.dev`
### Future Roadmap: https://gist.github.com/AZatvornitskiy/5013360


Installation Quickstart
-----------------------

After downloading, type:

    make setup              # get-deps compile test
    make test               # start a unit tests
    make get-couchdb-deps   # Optional: clone couch db 1.2.x git from apache repos if you want to use a Couch DB as dependency
    make setup-dev-couchdb  # Optional: install a development CouchDB, so you can use a `deps/couchdb/utils/./run -i` command for starting the development DB
    make acceptance         # Optional: start an acceptance tests, requires a development CouchDB

After passed tests, put in `couch_normalizer` to `couchdb` bash:

    COUCH_GEARS_PA_OPTIONS="-pa /path/to/couch_gears/current/ebin"
    ERL_START_OPTIONS="$ERL_OS_MON_OPTIONS -sasl errlog_type error +K true +A 4 $COUCH_GEARS_PA_OPTIONS"

configure a Couch DB `local.ini` config:

    [daemons]
    couch_gears={'Elixir-CouchGears-Initializer', start_link, [[{env, <<"dev">>}]]}

create your first `hello_world` gear application:

    # exports local elixir dependency to the PATH
    export PATH=$PATH:deps/elixir/bin
    mix gear

    # or use `elixir` commands directly
    deps/elixir/bin/elixir deps/elixir/bin/mix gear

start a Couch DB server:

    deps/couchdb/utils/./run -i # or
    couchdb -i

That is it:

    curl -H"Content-Type: application/json" http://127.0.0.1:5984/db/_gears
    => {"ok":"Hello World"}


Walk-through `hello_world` application
--------------------------------------

Check the origin [Dynamo Walk-through](https://github.com/elixir-lang/dynamo#walk-through) documentation.

`HelloWorldApplication` module defined at `apps/hello_world/config/application.ex` which is your specific `CouchGears.App` initializer.

```elixir
defmodule HelloWorldApplication do
  use CouchGears.App

  config :gear,
    handlers: [
      # Handles request which doesn't belong to any kind of `db`
      # global: true,

      # Sets a particular `db` names which application should handle
      # dbs: [:a, :b]
      # Sets a `dbs: :all` option which belongs to all available `dbs`
      dbs: :all
    ]


  config :dynamo,
  # Compiles modules as they are needed
  # compile_on_demand: true,
  # Reload modules after they are changed
  # reload_modules: true,

  # The environment this Dynamo runs on
  env: CouchGears.env,

  # The endpoint to dispatch requests too
  endpoint: ApplicationRouter


  # The environment specific options
  environment "dev" do
    config :dynamo, compile_on_demand: true, reload_modules: true
  end

  environment %r(prod|test) do
    config :dynamo, compile_on_demand: true, reload_modules: false
  end
end

```

`ApplicationRouter` defined at `apps/hello_world/web/routes/application_router.ex`

```elixir
defmodule ApplicationRouter do
  use CouchGears.Router

  # Application level filters

  # Sets CouchGears version info as a 'Server' response header.
  # filter CouchGears.Filters.ServerVersion

  # Sets 'Content-Type: application/json' response header.
  filter CouchGears.Filters.ResponseTypeJSON

  # Accepts only 'Content-Type: application/json' request. Otherwise, returns a '400 Bad Request' response
  # filter CouchGears.Filters.OnlyRequestTypeJSON


  get "/" do
    conn.resp_body([{:ok, "Hello World"}], :json)
  end
end

```

License
-------

`Couch Gears` source code is released under Apache 2 License.
Check [LICENSE](https://github.com/datahogs/couch_gears/blob/master/LICENSE) and [NOTICE](https://github.com/datahogs/couch_gears/blob/master/NOTICE) files for more details.
