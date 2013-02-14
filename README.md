[![Build Status](https://travis-ci.org/datahogs/couch_gears.png)](https://travis-ci.org/datahogs/couch_gears)

Couch Gears: A sexy convenience for customizing your Couch DB nodes as you need
-------------------------------------------------------------------------------

In short, `Couch Gears` is a spatial extension for [Apache CouchDB](https://github.com/apache/couchdb) based on [Dynamo](https://github.com/josevalim/dynamo) and tries to make the most out of this wonderful marriage of technologies.


### Status: under active development and  scoping (YOU're welcome!)
### Current version: `0.6.dev`


Installation Quickstart
-----------------------

After downloading, type:

    make setup              # get-deps compile test
    make get-couchdb-deps   # Optional: clone couch db 1.2.x git from apache repos if you want to use a Couch DB as dependency
    make setup-dev-couchdb  # Optional: install Couch DB development version, and you'll have a `deps/couchdb/utils/./run -i`

After passed tests, put in `couch_normalizer` to `couchdb` bash:

    COUCH_NORMALIZER_PA_OPTIONS="-pa /path/to/couch_normalizer/current/ebin"
    ERL_START_OPTIONS="$ERL_OS_MON_OPTIONS -sasl errlog_type error +K true +A 4 $COUCH_NORMALIZER_PA_OPTIONS"

configure a Couch DB `local.ini` config:

    [daemons]
    couch_gears={'Elixir-CouchGears-Initializer', start_link, [[{env, <<"dev">>}]]}

create your first `hello_world` gear application:

    # export local elixir dependency to the PATH
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


Have an useful practice! )


License
-------

`Couch Gears` source code is released under Apache 2 License.
Check [LICENSE](https://github.com/datahogs/couch_gears/blob/master/LICENSE) and [NOTICE](https://github.com/datahogs/couch_gears/blob/master/NOTICE) files for more details.
