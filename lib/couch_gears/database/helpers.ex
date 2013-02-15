defmodule CouchGears.Database.Helpers do
  @moduledoc """
  This module contains helper/adapter functions
  for interoperability with CouchDB documents and its internal representations.

  Some of functions just only a convenience which is used for acceptance/unit testing.
  """

  @doc """
  Returns `transform` function which is used for initializing a `HashDict`
  """
  def from_list_to_hash_dict_transform do
    fn({key, value}) ->
      case value do
        { list_value } -> {key, HashDict.new(list_value, from_list_to_hash_dict_transform)}
        _ -> {key, value}
      end
    end
  end

  @doc """
  Returns a list from `HashDict`. It doesn't used a `HashDict.to_list/1` function, because a document
  could contain a nested `HashDict`s
  """
  def from_hash_dict_to_list(hash_dict) do
    Enum.map hash_dict.keys(), fn(el) ->
      element = hash_dict[el]
      case is_hash_dict?(element) do
        true -> {el, {from_hash_dict_to_list(element)}}
        false -> {el, element}
      end
    end
  end

  @doc """
  Returns true in case `dict` is a `HashDict`
  """
  def is_hash_dict?(dict), do: is_record(dict, HashDict) || false
end