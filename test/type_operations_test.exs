defmodule TypeOperationsTest do
  use ExUnit.Case
  doctest ElixirSessions.TypeOperations

  test "small example" do
    {:@, _, [spec]} =
      quote do
        @spec function(integer, integer()) :: number
      end

    {:spec, _, [{:"::", _, [{spec_name, _, args_types}, return_type]}]} = spec

    args_types = ElixirSessions.TypeOperations.spec_get_type(args_types)
    return_type = ElixirSessions.TypeOperations.spec_get_type(return_type)

    assert args_types == {:list, [:integer, :integer]}
    assert return_type == :number
  end

  test "all accepted example" do
    {:@, _, [spec]} =
      quote do
        @spec function(
                :any,
                :atom,
                :binary,
                :boolean,
                :float,
                :integer,
                nil,
                :number,
                :pid,
                :string,
                :no_return
              ) :: :any
      end

    {:spec, _, [{:"::", _, [{spec_name, _, args_types}, return_type]}]} = spec

    args_types = ElixirSessions.TypeOperations.spec_get_type(args_types)
    return_type = ElixirSessions.TypeOperations.spec_get_type(return_type)

    assert args_types == {:list, [:any, :atom, :binary, :boolean, :float, :integer, nil, :number, :pid, :string, :no_return]}
    assert return_type == :any
  end

  test "list/tuple example" do
    {:@, _, [spec]} =
      quote do
        @spec function(integer, [integer]) :: {number}
      end

    {:spec, _, [{:"::", _, [{spec_name, _, args_types}, return_type]}]} = spec

    args_types = ElixirSessions.TypeOperations.spec_get_type(args_types)
    return_type = ElixirSessions.TypeOperations.spec_get_type(return_type)

    assert args_types == {:list, [:integer, {:list, [:integer]}]}
    assert return_type == {:tuple, [:number]}
  end

  test "literal example" do
    {:@, _, [spec]} =
      quote do
        @spec function(78, nil, :abc, "hello") :: :ok
      end

    {:spec, _, [{:"::", _, [{spec_name, _, args_types}, return_type]}]} = spec

    args_types = ElixirSessions.TypeOperations.spec_get_type(args_types)
    return_type = ElixirSessions.TypeOperations.spec_get_type(return_type)

    assert args_types == {:list, [:integer, nil, :abc, :binary]}
    assert return_type == :ok
  end

  test "further literals example" do
    {:@, _, [spec]} =
      quote do
        @spec function(7676.4, true, :false, 78, nil, pid, "hello") :: :ok
      end

    {:spec, _, [{:"::", _, [{spec_name, _, args_types}, return_type]}]} = spec

    args_types = ElixirSessions.TypeOperations.spec_get_type(args_types)
    return_type = ElixirSessions.TypeOperations.spec_get_type(return_type)

    assert args_types == {:list, [:float, true, false, :integer, nil, :pid, :binary]}
    assert return_type == :ok
  end


  test "edge tuple example" do
    {:@, _, [spec]} =
      quote do
        @spec function({number, integer, :ok}) :: :ok
      end

    {:spec, _, [{:"::", _, [{spec_name, _, args_types}, return_type]}]} = spec

    args_types = ElixirSessions.TypeOperations.spec_get_type(args_types)
    return_type = ElixirSessions.TypeOperations.spec_get_type(return_type)

    assert args_types == {:list, [{:tuple, [:number, :integer, :ok]}]}
    assert return_type == :ok
  end

  test "error type" do
    {:@, _, [spec]} =
      quote do
        @spec function(abc) :: number
      end

    {:spec, _, [{:"::", _, [{spec_name, _, args_types}, return_type]}]} = spec

    args_types = ElixirSessions.TypeOperations.spec_get_type(args_types)
    return_type = ElixirSessions.TypeOperations.spec_get_type(return_type)

    assert args_types == {:list, [:error]}
    assert return_type == :number
  end


  test "subtype? atom 1" do
    type1 = :atom
    type2 = :atom
    assert ElixirSessions.TypeOperations.subtype?(type1, type2) === true
    assert ElixirSessions.TypeOperations.subtype?(type2, type1) === true
  end

  test "subtype? atom 2" do
    type1 = :abc
    type2 = :atom
    assert ElixirSessions.TypeOperations.subtype?(type1, type2) === true
    assert ElixirSessions.TypeOperations.subtype?(type2, type1) === false
  end

  test "subtype? atom 3" do
    type1 = :abc
    type2 = :def
    assert ElixirSessions.TypeOperations.subtype?(type1, type2) === false
    assert ElixirSessions.TypeOperations.subtype?(type2, type1) === false
  end

  test "subtype? atom 4" do
    type1 = :atom
    type2 = :abc
    assert ElixirSessions.TypeOperations.subtype?(type1, type2) === false
    assert ElixirSessions.TypeOperations.subtype?(type2, type1) === true
  end

  test "subtype? number 1" do
    type1 = :integer
    type2 = :number
    assert ElixirSessions.TypeOperations.subtype?(type1, type2) === true
    assert ElixirSessions.TypeOperations.subtype?(type2, type1) === false
  end

  test "subtype? number 2" do
    type1 = :integer
    type2 = :float
    assert ElixirSessions.TypeOperations.subtype?(type1, type2) === true
    assert ElixirSessions.TypeOperations.subtype?(type2, type1) === false
  end

  test "subtype? number 3" do
    type1 = :float
    type2 = :number
    assert ElixirSessions.TypeOperations.subtype?(type1, type2) === true
    assert ElixirSessions.TypeOperations.subtype?(type2, type1) === false
  end

  test "subtype? tuple" do
    type1 = {:tuple, [:atom, :integer, :abc]}
    type2 = {:tuple, [:atom, :integer, :atom]}
    assert ElixirSessions.TypeOperations.subtype?(type1, type2) === true
    assert ElixirSessions.TypeOperations.subtype?(type2, type1) === false
  end


  test "subtype? list" do
    type1 = {:list, [:abc]}
    type2 = {:list, [:atom]}
    assert ElixirSessions.TypeOperations.subtype?(type1, type2) === true
    assert ElixirSessions.TypeOperations.subtype?(type2, type1) === false
  end

  test "subtype? list - maybe todo remove" do
    type1 = {:list, [:atom, :integer, :abc]}
    type2 = {:list, [:atom, :integer, :atom]}
    assert ElixirSessions.TypeOperations.subtype?(type1, type2) === true
    assert ElixirSessions.TypeOperations.subtype?(type2, type1) === false
  end

  test "subtype? bad" do
    assert ElixirSessions.TypeOperations.subtype?(:abc, :number) === false
    assert ElixirSessions.TypeOperations.subtype?({:tuple, [:atom]}, {:list, [:abc]}) === false
    assert ElixirSessions.TypeOperations.subtype?(:float, :atom) === false
  end
end