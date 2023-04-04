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

  def censor_tweet(pid, tweet_text) do
    GenServer.cast(pid, {:censor_tweet, tweet_text})
  end

  def handle_cast({:censor_tweet, tweet_text}, state) do
    tweet_text = Regex.replace(~r/(\w+)/, tweet_text, fn word ->
      if Enum.member?(state, word) do
        String.replace(word, ~r/./, "*")
      else
        word
      end
    end)
    IO.puts("Redacted text: #{inspect(tweet_text)}")
    {:noreply, state}
  end

  # {:ok, pid} = RedactedText.start_link
  # RedactedText.censor_tweet(pid, "fuck bafhjae shit fuss")

end
