defmodule Aggregator do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__,  nil, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  def get_tweet_data({id, data}) do
    GenServer.cast(__MODULE__, {:get_tweet_data, id, data})
  end

  def handle_cast({:get_tweet_data, id, data}, state) do
    tweet_data = Map.get(state, id, {})
    |> Tuple.append(data)

    if tuple_size(tweet_data) == 3 do
      Batcher.get_batch(tweet_data)
      {:noreply, Map.delete(state, id)}
    else
      {:noreply, Map.put(state, id, tweet_data)}
    end
  end
end

# {:ok, pid} = ReaderSupervisor.start_link
