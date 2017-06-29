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
MultiPostgrexex.query(
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