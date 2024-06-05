defmodule Graphex.TestHelper do
  @graphex_adapter :"#{System.get_env("DLEX_ADAPTER", "grpc")}"
  @offset String.to_integer(System.get_env("DLEX_PORT_OFFSET", "0"))

  def opts() do
    case @graphex_adapter do
      :http -> [transport: :http, port: 8080 + @offset]
      :grpc -> [transport: :grpc, port: 9080 + @offset]
    end
  end

  def drop_all(pid) do
    Graphex.alter(pid, %{drop_all: true})
  end

  def adapter(), do: @graphex_adapter
end

defmodule Graphex.Geo do
  use Ecto.Type
  defstruct lon: 0.0, lat: 0.0

  @impl true
  def type(), do: :geo

  @impl true
  def cast(%{lat: lat, lon: lon}), do: {:ok, %__MODULE__{lat: lat, lon: lon}}
  def cast(_), do: :error

  @impl true
  def load(%{"type" => "Point", "coordinates" => [lat, lon]}) do
    {:ok, %__MODULE__{lat: lat, lon: lon}}
  end

  @impl true
  def dump(%__MODULE__{lat: lat, lon: lon}) do
    {:ok, %{"type" => "Point", "coordinates" => [lat, lon]}}
  end

  def dump(_), do: :error
end

defmodule Graphex.User do
  use Graphex.Node

  schema "user" do
    field(:name, :string, index: ["term"])
    field(:age, :integer)
    field(:friends, {:list, :uid})
    field(:location, Graphex.Geo)
    field(:cache, :any, virtual: true)
  end
end

defmodule Graphex.TestRepo do
  use Graphex.Repo, otp_app: :graphex, modules: [Graphex.User]
end

to_skip =
  case Graphex.TestHelper.adapter() do
    :http -> [:grpc]
    :grpc -> [:http]
  end

{:ok, _} = Application.ensure_all_started(:grpc)
ExUnit.start(exclude: [:skip | to_skip])
