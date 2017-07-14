defmodule MultiPostgrex.Pool.Worker do
  use GenServer

  require Logger

  def start_link(connection_options) do
    GenServer.start_link(__MODULE__, %{conn: nil, connection_options: connection_options}, [])
  end

  def init(state) do
    {:ok, state}
  end

  defmodule Connector do

    def connect(connection_options) do
      IO.inspect(connection_options)

      {:ok, client} = Postgrex.start_link(
        hostname: connection_options[:hostname],
        port: connection_options[:port],
        username: connection_options[:username] || "",
        password: connection_options[:password] || "",
        database: connection_options[:database] || "",
        timeout: connection_options[:timeout],
        pool_timeout: connection_options[:pool_timeout]
      )

      client
    end

    @doc """
    Checking process alive or not in case if we don't have connection we should
    connect to redis server.
    """
    def ensure_connection(conn, connection_options) do
      if Process.alive?(conn) do
        conn
      else
        Logger.debug "[Connector] Postgrex connection has died, it will renew connection."
        connect(connection_options)
      end
    end
  end

  @doc false
  def handle_call(%{sql: sql, args: args}, _from, %{conn: nil, connection_options: connection_options}) do
    conn = Connector.connect(connection_options)
    results = Postgrex.query!(conn, sql, args)
    {:reply, results, %{conn: conn, connection_options: connection_options}}
  end

  @doc false
  def handle_call(%{sql: sql, args: args}, _from, %{conn: conn, connection_options: connection_options}) do
    conn = Connector.ensure_connection(conn, connection_options)
    results = Postgrex.query!(conn, sql, args)
    {:reply, results, %{conn: conn, connection_options: connection_options}}
  end

end
