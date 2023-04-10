defmodule Batcher do
  use GenServer
  require Logger

  def start_link(state) do
    Logger.info("Starting Batcher.")
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init({batch_size, batch_timeout}) do
    Process.send_after(self(), :print_batch_timeout, batch_timeout)
    {:ok, %{batch_size: batch_size, batch_timeout: batch_timeout, tweets: []}}
  end

  def handle_info(:print_batch_timeout, state) do
    IO.puts("BATCH TIMEOUT:\n")
    Enum.map(state[:tweets], fn tweet -> IO.puts("Tweet Text: #{inspect(tweet)}") end)
    IO.puts("\n")
    Process.send_after(self(), :print_batch_timeout, state[:batch_timeout])
    {:noreply, %{batch_size: state[:batch_size], batch_timeout: state[:batch_timeout], tweets: []}}
  end

  def handle_info(:print_batch, state) do
    IO.puts("BATCH:\n")
    Enum.map(state[:tweets], fn tweet -> IO.puts("Tweet Text: #{inspect(tweet)}") end)
    IO.puts("\n")
    {:noreply, %{batch_size: state[:batch_size], batch_timeout: state[:batch_timeout], tweets: []}}
  end

  def get_batch(tweet) do
    GenServer.cast(__MODULE__, {:get_batch, tweet})
  end

  def handle_cast({:get_batch, tweet}, state) do
    new_state = [tweet| state[:tweets]]
    if length(new_state) >= state[:batch_size] do
      send(self(), :print_batch)
    end
    {:noreply, %{batch_size: state[:batch_size], batch_timeout: state[:batch_timeout], tweets: new_state}}
  end
end

# {:ok, pid} = ReaderSupervisor.start_link
# {:ok, pid} = Batcher.start_link({10, 1000})
# send(Batcher, {:get_batch, "hashtag_list"})
