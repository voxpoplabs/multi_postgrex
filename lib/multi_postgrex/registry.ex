defmodule MultiPostgrex.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: MultiPostgrex.Registry)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensures there is a bucket associated to the given `name` in `server`.
  """
  def create(server, postgrex_setup) do
    pid = GenServer.call(server, {:create, postgrex_setup})
    { :ok, pid }
  end

  ## Server Callbacks

  def init(:ok) do
    names = %{}
    refs  = %{}
    {:ok, {names, refs}}
  end

  def handle_call({:lookup, name}, _from, {names, _} = state) do
    {:reply, Map.fetch(names, name), state}
  end

  def handle_call({:create, postgrex_setup}, _from, {names, refs}) do
    name = postgrex_setup[:name]

    if Map.has_key?(names, name) do
      {:reply, names[name], {names, refs}}
    else
      %{ name: name, connection_options: postgrex_setup[:get_connection_info].() }
      |> MultiPostgrex.Pool.Supervisor.start_postgrex_connection
      |> case do
        {:ok, pid} ->
          ref = Process.monitor(pid)
          refs = Map.put(refs, ref, name)
          names = Map.put(names, name, pid)
          {:reply, pid, {names, refs}}

        case_return_value ->
          IO.inspect("This Branch Is Not Yet Mitigated For.")
          {:reply, "pid", {names, refs}}
      end
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end