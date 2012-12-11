ELIXIR_PATH := deps/elixir/bin

setup: get-deps compile


get-deps:
	@ mkdir deps && cd deps && git clone -b 1.2.x git://github.com/apache/couchdb.git

compile: clean couch_gears test

clean:
	@ rm -rf ebin/ && PATH=$(PATH):$(ELIXIR_PATH) mix clean

couch_gears:
	@ PATH=$(PATH):$(ELIXIR_PATH) mix do deps.get, compile

test: test_couch_gears

test_couch_gears:
	@ PATH=$(PATH):$(ELIXIR_PATH) mix test