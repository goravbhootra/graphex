# 0.5.1

* fix and enhance support for custom ecto types (see example `Graphex.Geo` in tests)
* fix a types diff not handled proparly in `Graphex.Repo` in alter_schema
* enahnce decoding/encoding in `Graphex.Repo` to return errors
* enhance `Repo.all` to accept query parameters.
  To enable `Repo.all` automatically detect types and converts to types, please include at least `dgraph.type`.
  Recommended query returns:

    ```
    uid
    dgraph.type
    expand(_all_)
    ```


# 0.5.0

* enahnce `mutate` API to support multiple mutations and set and delete combined
* do not sent invalid changeset data to DGraph
* fix creation of geo locations with `return_json: true` option
* add support for `best_effort` and `read_only` options for query

Backwards-incompatible changes:

* `Graphex.mutate` changed. Before: `Graphex.mutate(pid, %{query: query, condition: condition}, mutation, opts)`,
  now this changed to `Graphex.mutate(pid, %{query: query}, %{cond: condition, set: mutation}, opts)`. It allows
  now to combine `set` and `delete` in the same mutation and do multiple mutations in one:
    `Graphex.mutate(pid, %{query: query}, %{cond: condition, set: set, delete: delete}, opts)`
    `Graphex.mutate(pid, %{query: query}, [mutaion1, mutation2])`
* `Graphex.set` now doesn't accept `condition` in a query, `Graphex.mutate` should be used instead.
* `Graphex.mutate`, `Graphex.delete`, `Graphex.set` doesn't return uids or json directly, but adds it to a map:
  `%{uids: uids, json: json}` and additionally it has has key `queries` to return queries, which additionally
  were used for this mutation. This allows to get everything back, what DGraph returns.

# 0.4.1

* check dgraph 1.1.1 is supported
* fix upserts for http protocol

# 0.4.0

* Add support for conditions in upsert
* Add support for returning structs in Repo.all

Backwards-incompatible changes:

* `Graphex.mutate(pid, query, mutation, opts)` is now `Graphex.mutate(pid, %{query: query}, mutation, opts)`,
  additionally `Graphex.mutate(pid, %{query: query, condition: condition}, mutation, opts)`
* `Repo.all` defined via `Graphex.Repo` - could return structs(if type is defined) instead of pure jsons

# 0.3.2

* Rename dgraph.type to be without prefix `type.` as it do not needed anymore

# 0.3.1

* Add http support for DGraph `1.1.0`

# 0.3.0

As dgraph has breaking API change, this version supports DGraph only in version `1.1.0`, use
graphex in version `0.2.1` for using with DGraph `1.0.X`.

* support DGraph `1.1.0` (only for `grpc` at the moment)

# 0.2.1

* add support for upcoming `upsert` functionallity (only for `grpc`)
* fix dependency missconfiguration in `v0.2.0`

# 0.2.0

* fix leaking of gun connections on timeouts
* add `transport` option, which specifies if `grpc` or `http` transport should be used
* make `grpc` dependencies optional, so you can choose based on transport the dependencies

# 0.1.3

* add support to alter table in the same format (json) as it queried. Now you can use output of
  `Graphex.query_schema` in `Graphex.alter`.

Example of usage:

```
Graphex.alter(conn, [%{
  "index" => true,
  "predicate" => "user.name",
  "tokenizer" => ["term"],
  "type" => "string"
}])
```

* add initial basic language integrated features on top of dgraph adapter:
  * add `Graphex.Node` to define schemas
  * add `Graphex.Repo` to define something like `Ecto.Repo`, but specific for Dgraph with custom API
  * `Graphex.Repo` supports `Ecto.Changeset` (and `Graphex.Node` schemas supports `Ecto.Changeset`),
  ecto is optional

Example usage:

```
defmodule User do
  use Graphex.Node

  schema "user" do
    field :name, :string, index: ["term"]
    field :age, :integer
    field :owns, :uid
  end
end

defmodule Repo do
  use Graphex.Repo, otp_app: :test, modules: [User]
end

%User{uid: uid} = Repo.mutate!(%User{name: "Alice", age: 29})
%User{name: "Alice"} = Repo.get!(uid)
```

Casting of nodes to structs happens automatically, but you need to either specify module in
`modules` or register them once after `Repo` is started with `Repo.register(User)` to be
available for `Repo`.

To get `User` schema, can be `User.__schema__(:alter)` used or `Repo.snapshot` for all fields or
or `Repo.alter_schema()` to directly migrate/alter schema for `Repo`.

`Ecto.Changeset` works with `Graphex.Node` and `Graphex.Repo`.

Example usage:

```
changeset = Ecto.Changeset.cast(%User{}, %{"name" => "Alice", "age" => 20}, [:name, :age])
Repo.mutate(changeset)
```

# 0.1.2

* add timeout on grpc calls
* ensure client reconnection works on dgraph unavailibility
* optimize json encoding/decoding, fetch json library from environment on connection start

# 0.1.1

* fix adding default options by including as supervisor

# 0.1.0

First release!
