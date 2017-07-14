defmodule MultiPostgrex do

  def query(postgrex_setup, sql, args) do
    # Lookup postgrex and ensure the supervisor is running
    lookup postgrex_setup, fn _pid ->

      # Once the supervisor is running, get a postgrex worker from poolboy
      :poolboy.transaction(postgrex_setup[:name], fn(worker) ->

        # Send the command to the worker genserver which has the connection running
        GenServer.call(worker, %{sql: sql, args: args})
      end, postgrex_setup[:timeout] || 5000)
    end
  end

  defp lookup(postgrex_setup, callback) do
    case MultiPostgrex.Registry.create(MultiPostgrex.Registry, postgrex_setup) do
      { :ok, pid } -> callback.(pid)
      _ -> { :error, "Registry not working" }
    end
  end

end
