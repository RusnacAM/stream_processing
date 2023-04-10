defmodule EngagementRatio do
  use GenServer
  require Logger

  def start_link(worker) do
    Logger.info("Starting worker: #{worker}")
    GenServer.start(__MODULE__, worker)
  end

  def init(state) do
    {:ok, state}
  end

  def get_engagement(pid, tweet_data) do
    GenServer.cast(pid, {:get_engagement, tweet_data})
  end

  def handle_cast({:get_engagement, tweet_data}, state) do
    username = tweet_data["user"]["name"]
    favourites = if tweet_data["retweeted_status"]["favorite_count"] == nil do
      tweet_data["favorite_count"]
    else
      tweet_data["retweeted_status"]["favorite_count"]
    end

    retweets = if tweet_data["retweeted_status"]["retweet_count"] == nil do
      tweet_data["retweet_count"]
    else
      tweet_data["retweeted_status"]["retweet_count"]
    end

    followers = tweet_data["user"]["followers_count"]

    engagement_ratio = if followers != 0 do
      (favourites + retweets) / followers
    else
      0
    end

    IO.puts("Engagement Ratio: #{inspect(engagement_ratio)}")
    UserEngagement.get_user_engagement(username, engagement_ratio)
    {:noreply, state}
  end

end

# {:ok, pid} = PrinterSupervisor.start_link
# {:ok, pid} = ReaderSupervisor.start_link
