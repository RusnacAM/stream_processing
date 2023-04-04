defmodule Printer do
  use GenServer
  require Logger

  @min_time 5
  @max_time 50

  def start_link(worker) do
    Logger.info("Starting worker: #{worker}")
    GenServer.start_link(__MODULE__, worker)
  end

  def init(state) do
    {:ok, state}
  end

  def print_text(pid, text) do
    GenServer.cast(pid, {:print_text, text})
  end

  def handle_cast({:print_text, "kill process"}, state) do
    Logger.info("Process with id #{state} is being terminated")
    exit(:killed)
  end

  def handle_cast({:print_text, text}, state) do
    tweet_text = "Tweet text: #{inspect(text)}"
    IO.puts(tweet_text)
    Process.sleep(Enum.random(@min_time..@max_time))
    {:noreply, state}
  end

  # {:ok, pid} = PrinterSupervisor.start_link
  # {:ok, pid} = ReaderSupervisor.start_link

end
