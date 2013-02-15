setup: get-deps compile test


get-couchdb-deps:
	@ cd deps && git clone -b 1.2.x git://github.com/apache/couchdb.git

setup-dev-couchdb:
	@ cd deps/couchdb && ./bootstrap && ./configure && make dev


get-deps:
	@ ./rebar get-deps make
	@ cd deps/elixir && make compile
	@ deps/elixir/bin/elixir deps/elixir/bin/mix deps.get


compile: clean elixir

clean:
	@ rm -rf ebin/ && deps/elixir/bin/elixir deps/elixir/bin/mix clean

elixir:
	@ deps/elixir/bin/elixir deps/elixir/bin/mix compile


test: test_elixir

test_elixir:
	@ deps/elixir/bin/elixir deps/elixir/bin/mix test

acceptance:
	@ curl -H"Content-Type: application/json" http://127.0.0.1:5984/_gears/_test