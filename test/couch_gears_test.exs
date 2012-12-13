Code.require_file "../test_helper.exs", __FILE__

defmodule CouchGearsTest do
  use ExUnit.Case, async: true

  alias CouchGears, as: Subject

  def teardown_all(_), do: Subject.env("dev")


  test "serves application environments" do
    assert Subject.env == "dev"

    System.put_env("MIX_ENV", "test")
    assert Subject.env == "test"

    Subject.env("prod")
    assert Subject.env == "prod"
  end

end