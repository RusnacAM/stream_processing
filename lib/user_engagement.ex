defmodule UserEngagement do
  use GenServer
  require Logger

  def start_link(state) do
    Logger.info("User engagement analyzer started.")
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_) do
    {:ok, %{users: %{}}}
  end

  def get_user_engagement(username, ratio) do
    GenServer.cast(__MODULE__, {:get_user_engagement, username, ratio})
  end

  def handle_cast({:get_user_engagement, username, ratio}, state) do
    val = Map.get(state[:users], username, 0)
    new_state = Map.put(state[:users], username, val + ratio)

    # IO.puts("User Engagement Ratio: #{username}: #{val + ratio} ")
    {:noreply, %{users: new_state}}
  end
end
