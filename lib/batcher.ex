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

  def handle_info(:send_batch, state) do
    for {id, {tweet, {user, engagement}, sentiment}} <- state[:tweets] do
      # IO.puts("#{id}\n#{user}\n#{tweet}\n#{engagement}\n#{sentiment}\n")
      Database.insert_tweet(id, tweet, engagement, sentiment)
      Database.insert_user(id, user)
    end
    {:noreply, %{batch_size: state[:batch_size], batch_timeout: state[:batch_timeout], tweets: [], prev_print: System.system_time(:millisecond)}}
  end

  def get_batch(tweet_data) do
    GenServer.cast(__MODULE__, {:get_batch, tweet_data})
  end

  def handle_cast({:get_batch, tweet_data}, state) do
    new_state = [tweet_data| state[:tweets]]
    prev_time = state[:prev_print]
    curr_time = System.system_time(:millisecond)
    elapsed_time = curr_time - prev_time
    if length(new_state) >= state[:batch_size] do
      send(self(), :send_batch)
    else
      if elapsed_time >= state[:batch_timeout] do
        send(self(), :send_batch)
      end
    end
    {:noreply, %{batch_size: state[:batch_size], batch_timeout: state[:batch_timeout], tweets: new_state, prev_print: state[:prev_print]}}
  end
end

# {:ok, pid} = ReaderSupervisor.start_link
# {:ok, pid} = Batcher.start_link({10, 1000})
