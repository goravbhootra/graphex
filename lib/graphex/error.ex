defmodule Graphex.Error do
  @moduledoc """
  Dgraph or connection error are wrapped in Graphex.Error.
  """
  defexception [:reason, :action]

  @type t :: %Graphex.Error{}

  @impl true
  def message(%{action: action, reason: reason}) do
    "#{action} failed with #{inspect(reason)}"
  end
end
