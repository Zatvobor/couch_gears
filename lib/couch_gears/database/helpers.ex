defmodule CouchGears.Database.Helpers do
  @moduledoc false

  @doc """
  Converts a document body list to HashDict container
  """
  def from_list_to_hash_dict_callback do
    fn({key, value}) ->
      case value do
        { list_value } -> {key, HashDict.new(list_value, from_list_to_hash_dict_callback)}
        _ -> {key, value}
      end
    end
  end

  @doc """
  Returns a list container from HashDict
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
  Returns true when HashDict else - false
  """
  def is_hash_dict?(dict) when is_record(dict, HashDict) do
    true
  end

  @doc false
  def is_hash_dict?(value) do
    false
  end
end