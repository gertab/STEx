defmodule ElixirSessions.Common do

  @typedoc """
  Abstract Syntax Tree (AST)
  """
  @type ast() :: Macro.t()

  @typedoc """
  Information related to a function body.
  """
  @type info() :: %{
          # recursion: boolean(),
          call_recursion: atom,
          function_name: atom,
          arity: arity
          # session_type: any
          # todo maybe add __module__
        }

  #todo change to defstruct

  @typep branch_type() :: %{atom => session_type}

  @typep choice_type() :: %{atom => session_type}

  @typedoc """
  A session type list of session operations.

  A session type may: `receive` (or dually `send` data), `branch` (or make a `choice`) or `recurse`.
  """
  @type session_type() ::
          [
            {:recv, any}
            | {:send, any}
            | {:branch, branch_type}
            | {:call_recurse, any}
            | {:choice, choice_type}
            | {:recurse, any, session_type}
          ]
end