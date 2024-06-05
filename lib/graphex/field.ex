defmodule Graphex.Field do
  @type type ::
          :string
          | :integer
          | :float
          | :boolean
          | :datetime
          | :geo
          | :password
          | :list
          | :set
          | :uid
          | :default
          | :bytes
          | :map
          | :auto

  @type t :: %__MODULE__{
          name: atom(),
          type: type(),
          db_name: String.t(),
          alter: map() | nil,
          opts: Keyword.t()
        }

  defstruct [:name, :type, :db_name, :alter, :opts]
end
