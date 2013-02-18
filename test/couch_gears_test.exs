Code.require_file "../test_helper.exs", __FILE__

defmodule CouchGearsTest do
  use ExUnit.Case, async: true

  import CouchGears

  teardown_all do
    env("dev")
  end


  test "serves application environments" do
    assert env == "test"

    System.put_env("MIX_ENV", "test")
    assert env == "test"

    env("prod")
    assert env == "prod"
  end

end