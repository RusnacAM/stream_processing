defmodule Reader do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      %{
        id: :tweets1,
        start: {SseReader, :start_link, ["http://localhost:4000/tweets/1"]}
      },
      %{
        id: :tweets2,
        start: {SseReader, :start_link, ["http://localhost:4000/tweets/2"]}
      },
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

# {:ok, pid} = Reader.start_link
# {:ok, pid} = Printer.start_link

defmodule SseReader do
  use GenServer

  def start_link(url) do
    GenServer.start_link(__MODULE__, url: url)
  end

  def init([url: url]) do
    IO.puts "Connecting to stream..."
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

  defp read_stream("event: \"message\"\n\ndata: " <> message) do
    {success, data} = Jason.decode(String.trim(message))

    if success == :ok do
      tweet = data["message"]["tweet"]
      text = tweet["text"]
      hashtag = tweet["entities"]
      Printer.print_text(text)
      #IO.puts "Received message: #{inspect hashtag}"
    else
      IO.puts "Failed to decode message: #{inspect data}"
    end

    IO.puts("\n")
  end
end

# {:ok, pid} = Printer.start_link
# SseReader.start_link("http://localhost:4000/tweets/1")
