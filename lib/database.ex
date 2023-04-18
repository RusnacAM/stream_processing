defmodule Database do
  use GenServer
  require Logger

  def start_link(_) do
    Logger.info("Starting Database.")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    tweetTable = :ets.new(:tweets, [:set, :public])
    userTable = :ets.new(:users, [:set, :public])
    Process.send_after(self(), :inspectTab, 5000)
    {:ok, %{tweetTable: tweetTable, userTable: userTable}}
  end

  def insert_tweet(tweetID, tweet, engagement, sentiment) do
    GenServer.cast(__MODULE__, {:insert_tweet, tweetID, tweet, engagement, sentiment})
  end

  def handle_cast({:insert_tweet, tweetID, tweet, engagement, sentiment}, state) do
    :ets.insert(state[:tweetTable], {tweetID, tweet, engagement, sentiment})
    {:noreply, %{tweetTable: state[:tweetTable], userTable: state[:userTable]}}
  end

  def insert_user(userID, username) do
    GenServer.cast(__MODULE__, {:insert_user, userID, username})
  end

  def handle_cast({:insert_user, userID, username}, state) do
    :ets.insert(state[:userTable], {userID, username})
    {:noreply, %{tweetTable: state[:tweetTable], userTable: state[:userTable]}}
  end

  def handle_info(:inspectTab, state) do
    IO.puts("---------------TWEETS TABLE---------------")
    IO.inspect(:ets.tab2list(state[:tweetTable]))
    IO.puts("---------------USERS TABLE---------------")
    IO.inspect(:ets.tab2list(state[:userTable]))

    Process.send_after(self(), :inspectTab, 5000)
    {:noreply, %{tweetTable: state[:tweetTable], userTable: state[:userTable]}}
  end

end

# {:ok, pid} = ReaderSupervisor.start_link
