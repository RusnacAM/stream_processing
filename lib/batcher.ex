defmodule Batcher do
  use GenServer
  require Logger

  def start_link(state) do
    Logger.info("Starting Batcher.")
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init({batch_size, batch_timeout}) do
    {:ok, %{batch_size: batch_size, batch_timeout: batch_timeout, tweets: [], prev_print: System.system_time(:millisecond)}}
  end

  def handle_info(:print_batch_timeout, state) do
    IO.puts("--------BATCH TIMEOUT--------\n")
    for {data1, data2, data3} <- state[:tweets] do
      IO.puts("#{data1}\n#{data2}\n#{data3}\n")
    end
    {:noreply, %{batch_size: state[:batch_size], batch_timeout: state[:batch_timeout], tweets: [], prev_print: System.system_time(:millisecond)}}
  end

  def handle_info(:print_batch, state) do
    IO.puts("--------BATCH--------\n")
    for {data1, data2, data3} <- state[:tweets] do
      IO.puts("#{data1}\n#{data2}\n#{data3}\n")
    end
    {:noreply, %{batch_size: state[:batch_size], batch_timeout: state[:batch_timeout], tweets: [], prev_print: System.system_time(:millisecond)}}
  end

  def get_batch(tweet) do
    GenServer.cast(__MODULE__, {:get_batch, tweet})
  end

  def handle_cast({:get_batch, tweet}, state) do
    new_state = [tweet| state[:tweets]]
    prev_time = state[:prev_print]
    curr_time = System.system_time(:millisecond)
    elapsed_time = curr_time - prev_time
    if length(new_state) >= state[:batch_size] do
      send(self(), :print_batch)
    else
      if elapsed_time >= state[:batch_timeout] do
        send(self(), :print_batch_timeout)
      end
    end
    {:noreply, %{batch_size: state[:batch_size], batch_timeout: state[:batch_timeout], tweets: new_state, prev_print: state[:prev_print]}}
  end
end

# {:ok, pid} = ReaderSupervisor.start_link
# {:ok, pid} = Batcher.start_link({10, 1000})
