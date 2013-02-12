Code.require_file "../test_helper.exs", __FILE__
defmodule DatabaseHelpersTest do
  use ExUnit.Case, async: true
  alias CouchGears.Database.Helpers, as: Subject

  test :from_hash_dict_to_list do
    dict = HashDict.new([a: 1, b: 2, c: 3])
    assert Subject.from_hash_dict_to_list(dict) == [c: 3, b: 2, a: 1]

    dict = HashDict.new([a: 1, b: 2, c: HashDict.new([d: 3])])
    assert Subject.from_hash_dict_to_list(dict) == [c: {[d: 3]}, b: 2, a: 1]
  end

  test :from_list_to_hash_dict_transform do
     assert HashDict.new([a: 1, b: 2], Subject.from_list_to_hash_dict_transform) ==  HashDict.new([a: 1, b: 2])
     assert HashDict.new([a: 1, b: 2, d: {[c: 3]}], Subject.from_list_to_hash_dict_transform) ==  HashDict.new([a: 1, b: 2, d: HashDict.new([c: 3])])
  end

  test :is_hash_dict? do
    dict = HashDict.new([a: 1, b: 2, c: 3])
    assert Subject.is_hash_dict?(dict) == true
    assert Subject.is_hash_dict?([]) == false
  end

end