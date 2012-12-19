Code.require_file "../test_helper.exs", __FILE__

defmodule CouchGearsTest do
  use ExUnit.Case, async: true


  @subject CouchGears

  def teardown_all(_), do: @subject.env("dev")


  test "serves application environments" do
    assert @subject.env == "test"

    System.put_env("MIX_ENV", "test")
    assert @subject.env == "test"

    @subject.env("prod")
    assert @subject.env == "prod"
  end

end