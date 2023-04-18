defmodule SseReader do
  use GenServer
  require Logger

  def start_link(url) do
    Logger.info("Connecting to stream from #{url}")
    GenServer.start_link(__MODULE__, url: url)
  end

  def init([url: url]) do
    HTTPoison.get!(url, [], [recv_timeout: :infinity, stream_to: self()])
    {:ok, nil}
  end

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, _state) do
    read_stream(chunk)
    {:noreply, nil}
  end

  def handle_info(%HTTPoison.AsyncStatus{} = status, _state) do
    IO.puts "Connection status: #{inspect status}"
    {:noreply, nil}
  end

  def handle_info(%HTTPoison.AsyncHeaders{} = headers, _state) do
    IO.puts "Connection headers: #{inspect headers}"
    {:noreply, nil}
  end

  defp read_stream("event: \"message\"\n\ndata: {\"message\": panic}\n\n" <> message) do
    #Mediator.redirect_text("KILL PROCESS")
  end

  defp read_stream("event: \"message\"\n\ndata: " <> message) do
    {success, data} = Jason.decode(String.trim(message))

    if success == :ok do
      tweet_data = data["message"]["tweet"]
      Mediator.redirect_text(tweet_data)
      hashtags = data["message"]["tweet"]["entities"]["hashtags"]
      hashtag_list = Enum.map(hashtags, fn hashtag -> Map.get(hashtag, "text") end)
      redirect_hashtag(hashtag_list)
    end
    # IO.puts("\n")

  end

  def redirect_hashtag(hashtag_list) do
    if(hashtag_list != []) do
      send(HashtagPrinter, {:get_hashtaglist, hashtag_list})
    end
  end
end

# {:ok, pid} = PrinterSupervisor.start_link
# {:ok, pid} = ReaderSupervisor.start_link
