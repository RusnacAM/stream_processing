defmodule HashtagPrinter do
  use GenServer
  require Logger

  def start_link() do
    Logger.info("Starting the most popular hashtag printer.")
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(hashtag_list) do
    Process.send_after(self(), :print_most_popular, 5000)
    {:ok, hashtag_list}
  end

  def handle_info(:print_most_popular, hashtag_list) do
    {most_popular, count} = hashtag_list
    |> Map.to_list()
    |> Enum.max_by(fn {_, count} -> count end)
    IO.inspect("Most popular hashtag: #{most_popular} with #{count} occurences")
    hashtag_list = %{}
    Process.send_after(self(), :print_most_popular, 5000)
    {:noreply, hashtag_list}
  end

  def handle_info({:get_hashtaglist, hashtags}, hashtag_list) do
    hashtag_list = Enum.reduce(hashtags, hashtag_list, fn hashtag, hashtag_list ->
      case Map.get(hashtag_list, hashtag) do
        nil -> Map.put(hashtag_list, hashtag, 1)
        count -> Map.put(hashtag_list, hashtag, count+1)
      end
    end)
    {:noreply, hashtag_list}
  end
end

# HashtagPrinter.start_link
# {:ok, pid} = ReaderSupervisor.start_link
