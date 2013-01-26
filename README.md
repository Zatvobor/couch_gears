Couch Gears: A sexy convenience for customizing your Couch DB API as you need
-----------------------------------------------------------------------------

### Status: under active development and scoping (YOU're welcome!)


Installation Quickstart
-----------------------

After downloading, type:

    make setup              # get-deps compile test
    make get-couchdb-deps   # Optional: clone couch db 1.2.x git from apache repos if you want to use a Couch DB as dependency
    make setup-dev-couchdb  # Optional: install Couch DB development version, and you'll have a `deps/couchdb/utils/./run -i`

After passed tests, put in `couch_normalizer` to `couchdb` bash:

    COUCH_NORMALIZER_PA_OPTIONS="-pa /var/www/couch_normalizer/current/ebin"
    ERL_START_OPTIONS="$ERL_OS_MON_OPTIONS -sasl errlog_type error +K true +A 4 $ELIXIR_PA_OPTIONS $COUCH_NORMALIZER_PA_OPTIONS"

configure a Couch DB `local.ini` config:

    [daemons]
    couch_gears={'Elixir-CouchGears-Initializer', start_link, [[{env, <<"dev">>}]]}

create your first `hello_world` gear:

    # push elixir to the PATH env
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


Have a nice hacking! )