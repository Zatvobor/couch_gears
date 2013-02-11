Code.require_file "../../../test_helper.exs", __FILE__

defmodule CouchGears.Database.HelpersTest do
  use ExUnit.Case, async: true

  import CouchGears.Database.Helpers


  test :is_hash_dict do
    assert is_hash_dict?(HashDict.new)
    refute is_hash_dict?(:dict.new())
  end

  test :from_list_to_hash_dict_callback do
    received = HashDict.new([{"a", 1}, {"b", 2}], from_list_to_hash_dict_callback)
    assert received ==  HashDict.new([{"a", 1}, {"b", 2}])

    received = HashDict.new([{"a", 1}, {"b", 2}, {"d", {[{"c", 3}]}}], from_list_to_hash_dict_callback)
    assert received ==  HashDict.new([{"a", 1}, {"b", 2}, {"d", HashDict.new([{"c", 3}])}])
  end

  test :from_hash_dict_to_list do
    dict = HashDict.new([{"a", 1}, {"b", 2}], from_list_to_hash_dict_callback)
    assert from_hash_dict_to_list(dict) == Enum.reverse [{"a", 1}, {"b", 2}]
  end

end