defmodule Graphex.Query do
  @moduledoc false

  @type mutation :: %{
          optional(:cond) => String.t(),
          optional(:set) => map | iodata,
          optional(:delete) => map | iodata
        }

  @type t :: %__MODULE__{
          type: Graphex.Type.Alter | Graphex.Type.Mutation | Graphex.Type.Query,
          query: String.t(),
          statement: [mutation] | map | iodata,
          parameters: any,
          txn_context: Graphex.Api.TxnContext.t(),
          json: atom,
          request: any
        }

  defstruct [:type, :query, :parameters, :statement, :json, :request, :txn_context]

  @type request :: any
  @callback request(t) :: request
end

defimpl DBConnection.Query, for: Graphex.Query do
  alias Graphex.{Query, Type}

  def parse(%Query{} = query, _), do: query
  def describe(query, opts), do: Type.describe(query, opts)
  def encode(query, parameters, opts), do: Type.encode(query, parameters, opts)
  def decode(query, result, opts), do: Type.decode(query, result, opts)
end
