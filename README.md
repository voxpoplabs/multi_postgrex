# MultiPostgrex

A postgrex database adapter that can connect to any database by passing configuration at runtime.

If a connection to the database previously been made, it will reuse that connection, otherwise it will start
up a new connection pool to that database.

## Installation

```elixir
def deps do
  [{:multi_postgrex, git: "https://github.com/voxpoplabs/multi_postgrex.git"}]
end
```

## Usage

```elixir
MultiPostgrex.query(
  %{
    name: :user_database,
    get_connection_information: fn () ->
      %{
        host: "127.0.0.1",
        db: "test_database"
      }
    end
  },
  "SELECT * FROM my_table",
  []
)
```

### Advanced Usage

This example would allow you to store multiple configurations in Redis and establish connections at runtime for querying.

```elixir
defmodule DynamicPostgrexAdapter do

  def query_database(database_name, sql, args) do
    setup_postgrex(database_name)
    |> MultiPostgrex.query(sql, args)
  end

  def setup_postgrex(database_name) do
    %{
      name: String.to_atom("postgrex_reporting_store_#{database_name}"),
      # closure so the database_name is passed to the function and not set during compliation
      get_connection_info: fn () ->
        get_connection_info(database_name)
      end
    }
  end

  # Function that will only be called when new connections need to be established
  # Otherwise MultiPostgrex will reuse existing connections
  def get_connection_info(database_name) do
    connection_info = Redis.get("#{database_name}_connection_info")
    %{
      hostname: connection_info["database_host"],
      database: connection_info["database_name"],
      port: connection_info["database_port"],
      username: connection_info["database_username"]
      password: connection_info["database_password"]
    }
  end

end
```

```elixir
DynamicPostgrexAdapter.query_database("sales", "SELECT * FROM orders", [])
```

