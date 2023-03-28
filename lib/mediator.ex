defmodule Mediator do
  use GenServer
  require Logger

  def start_link(printer_num) do
    GenServer.start_link(__MODULE__, printer_num, name: __MODULE__)
  end

  def init(printer_num) do
    total_printers = printer_num
    current_printer = 0
    {:ok, {total_printers, current_printer}}
  end

  def redirect_text(tweet) do
    GenServer.cast(__MODULE__, {:redirect_text, tweet})
  end

  def handle_cast({:redirect_text, tweet}, {total_printers, current_printer}) do
    curr_printer_num = current_printer + 1
    printer = :"printer#{curr_printer_num}"

    printer_pid = PrinterSupervisor.get_pid(printer)
    clean_tweet = tweet
    |> String.downcase()
    |> check_tweet()
    Printer.print_text(printer_pid, clean_tweet)
    {:noreply, {total_printers, rem(curr_printer_num, total_printers)}}
  end

  def check_tweet(tweet) do
    jason = File.read!("lib/swear-words.json")
    swear_words = Jason.decode!(jason)
    tweet = Regex.replace(~r/(\w+)/, tweet, fn word ->
      if Enum.member?(swear_words, word) do
        String.replace(word, ~r/./, "*")
      else
        word
      end
    end)
  end

end

# Mediator.start_link(3)
# Mediator.redirect_text("fajef")
# {:ok, pid} = PrinterSupervisor.start_link
