ELIXIR_PATH := deps/elixir/bin

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
	@ rm -rf ebin/ && PATH=$(PATH):$(ELIXIR_PATH) mix clean

elixir:
	@ PATH=$(PATH):$(ELIXIR_PATH) mix compile


test: test_elixir

test_elixir:
	@ PATH=$(PATH):$(ELIXIR_PATH) mix test