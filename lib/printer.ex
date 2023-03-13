defmodule Printer do
  use GenServer

  @min_time 5
  @max_time 50

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def print_text(text) do
    GenServer.call(__MODULE__, {:print_text, text})
  end

  def handle_call({:print_text, text}, from, state) do
    tweet_text = "Tweet text: #{inspect(text)}, from: #{inspect(from |> elem(0))}"
    Process.sleep(Enum.random(@min_time..@max_time))
    {:reply, IO.puts(tweet_text), state}
  end

end
