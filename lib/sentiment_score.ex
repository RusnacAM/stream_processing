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

  def get_sentiment(pid, tweet_text) do
    GenServer.cast(pid, {:get_sentiment, tweet_text})
  end

  def handle_cast({:get_sentiment, tweet_text}, state) do
    sentiment_pid = ReaderSupervisor.get_pid(:emotionvalues)
    tweet_text = tweet_text
    |> String.downcase()
    |> String.split(" ", trim: True)
    emotion_sum = Enum.map(tweet_text, fn word -> GenServer.call(sentiment_pid, {:get_score, word}) end)
    emotion_score = Enum.sum(emotion_sum) / length(emotion_sum)
    IO.puts("Sentiment Score: #{inspect(emotion_score)}")
    {:noreply, state}
  end
end

# {:ok, pid} = PrinterSupervisor.start_link
# {:ok, pid} = ReaderSupervisor.start_link
