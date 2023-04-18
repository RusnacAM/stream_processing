defmodule SentimentScore do
  use GenServer
  require Logger

  def start_link(worker) do
    Logger.info("Starting worker: #{worker}")
    GenServer.start(__MODULE__, worker)
  end

  def init(state) do
    {:ok, state}
  end

  def get_sentiment(pid, tweet_data) do
    GenServer.cast(pid, {:get_sentiment, tweet_data})
  end

  def handle_cast({:get_sentiment, tweet_data}, state) do
    tweet_id = tweet_data["id"]
    tweet_text = tweet_data["text"]
    sentiment_pid = ReaderSupervisor.get_pid(:emotionvalues)

    tweet_text = tweet_text
    |> String.downcase()
    |> String.split(" ", trim: True)
    emotion_sum = Enum.map(tweet_text, fn word -> GenServer.call(sentiment_pid, {:get_score, word}) end)
    emotion_score = Enum.sum(emotion_sum) / length(emotion_sum)

    # IO.puts("Sentiment Score: #{inspect(emotion_score)}")
    Aggregator.get_tweet_data({tweet_id, "Sentiment Score: #{emotion_score}"})
    {:noreply, state}
  end
end

# {:ok, pid} = PrinterSupervisor.start_link
# {:ok, pid} = ReaderSupervisor.start_link
