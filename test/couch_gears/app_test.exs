Code.require_file "../../test_helper.exs", __FILE__

defmodule CouchGears.AppTest do
  use ExUnit.Case, async: true

  import CouchGears.App


  test "doesn't normalize" do
    assert normalize_config([handlers: [dbs: :all, global: true]]) == [handlers: [dbs: :all, global: true]]
  end

  test "normalizes undefined config" do
    assert normalize_config([])   == [handlers: :undefined]
    assert normalize_config(nil)  == [handlers: :undefined]
  end

  test "normalizes global opts" do
    assert normalize_config([handlers: []])             == [handlers: [dbs: [], global: false]]
    assert normalize_config([handlers: [global: true]]) == [handlers: [dbs: [], global: true]]
  end

  test "normalizes dbs opts" do
    assert normalize_config([handlers: [dbs: :all]])  == [handlers: [global: false, dbs: :all]]
    assert normalize_config([handlers: [dbs: "all"]]) == [handlers: [dbs: [], global: false]]

    assert normalize_config([handlers: [dbs: {}]])          == [handlers: [dbs: [], global: false]]
    assert normalize_config([handlers: [dbs: ["a", "b"]]])  == [handlers: [dbs: [:a, :b], global: false]]
    assert normalize_config([handlers: [dbs: [:a, :b]]])    == [handlers: [dbs: [:a, :b], global: false]]
  end
end