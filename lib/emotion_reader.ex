defmodule EmotionReader do
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

  def handle_info(%HTTPoison.AsyncChunk{chunk: chunk}, state) do
    new_state = Enum.join([state, chunk], "")
    {:noreply, new_state}
  end

# EmotionReader.start_link("http://localhost:4000/emotion_values")

  def handle_info(%HTTPoison.AsyncStatus{} = status, _state) do
    IO.puts "Connection status: #{inspect status}"
    {:noreply, nil}
  end

  def handle_info(%HTTPoison.AsyncHeaders{} = headers, _state) do
    IO.puts "Connection headers: #{inspect headers}"
    {:noreply, nil}
  end

  def handle_info(%HTTPoison.AsyncEnd{} = async_end, state) do
    IO.puts "Stream ended: #{inspect async_end}"
    stream = String.split(state, "\r\n")
    new_state = Enum.map(stream, fn emotion ->
      String.split(emotion, "\t")
    end)
    |> Map.new(fn [sentiment, value] ->
    score = String.to_integer(String.at(value, String.length(value)-1))
    {sentiment, score}
    end)
    {:noreply, new_state}
  end

  def handle_call({:get_score, word},_from, state) do
    value = Map.fetch(state, word)
    score = if value == :error do
      0
    else
      {:ok, val} = value
      val
    end
    {:reply, score, state}
  end

end

# {ok, pid} = EmotionReader.start_link("http://localhost:4000/emotion_values")
# GenServer.call(pid, {:get_score, "spam"})
