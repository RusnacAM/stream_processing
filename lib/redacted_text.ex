defmodule RedactedText do
  use GenServer
  require Logger

  def start_link(worker) do
    Logger.info("Starting worker: #{worker}")
    GenServer.start(__MODULE__, worker)
  end

  def init(state) do
    jason = File.read!("lib/swear-words.json")
    swear_words = Jason.decode!(jason)
    {:ok, swear_words}
  end

  def censor_tweet(pid, tweet_data) do
    GenServer.cast(pid, {:censor_tweet, tweet_data})
  end

  def handle_cast({:censor_tweet, tweet_data}, state) do
    tweet_id = tweet_data["id"]
    tweet_text = tweet_data["text"]
    tweet_text = Regex.replace(~r/(\w+)/, tweet_text, fn word ->
      if Enum.member?(state, word) do
        String.replace(word, ~r/./, "*")
      else
        word
      end
    end)
    # Batcher.get_batch(tweet_text)
    # IO.puts("Redacted text: #{inspect(tweet_text)}")
    Aggregator.get_tweet_data({tweet_id, "Tweet Text: #{tweet_text}"})
    {:noreply, state}
  end

  # {:ok, pid} = RedactedText.start_link
  # RedactedText.censor_tweet(pid, "fuck bafhjae shit fuss")

end
