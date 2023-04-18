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

  def redirect_text(tweet_data) do
    GenServer.cast(__MODULE__, {:redirect_text, tweet_data})
  end

  def handle_cast({:redirect_text, tweet_data}, {total_printers, current_printer}) do
    curr_printer_num = current_printer + 1

    call_module(curr_printer_num, tweet_data, "RedactedText")
    call_module(curr_printer_num, tweet_data, "EngagementRatio")
    call_module(curr_printer_num, tweet_data, "SentimentScore")
    {:noreply, {total_printers, rem(curr_printer_num, total_printers)}}
  end

  # {:ok, pid} = ReaderSupervisor.start_link

  def call_module(curr_printer_num, tweet_data, module) do
    printer_name = String.to_atom("#{module}#{curr_printer_num}")
    case module do
      "RedactedText" ->
        sup_pid = ReaderSupervisor.get_pid(:redactedprinters)
        printer_pid = PrinterSupervisor.get_pid(curr_printer_num, sup_pid)
        call_redacted(printer_pid, tweet_data)
      "EngagementRatio" ->
        sup_pid = ReaderSupervisor.get_pid(:engagementprinters)
        printer_pid = PrinterSupervisor.get_pid(curr_printer_num, sup_pid)
        call_engagement(printer_pid, tweet_data)
      "SentimentScore" ->
        sup_pid = ReaderSupervisor.get_pid(:sentimentprinters)
        printer_pid = PrinterSupervisor.get_pid(curr_printer_num, sup_pid)
        call_sentiment(printer_pid, tweet_data)
      _ -> "No Match"
    end
  end

  def call_redacted(redacted_printer_pid, tweet_data) do
    RedactedText.censor_tweet(redacted_printer_pid, tweet_data)
  end

  def call_engagement(engagement_printer_pid, tweet_data) do
    EngagementRatio.get_engagement(engagement_printer_pid, tweet_data)
  end

  def call_sentiment(sentiment_printer_pid, tweet_data) do
    SentimentScore.get_sentiment(sentiment_printer_pid, tweet_data)
  end

end

# Mediator.start_link(3)
# Mediator.redirect_text("fajef")
# {:ok, pid} = PrinterSupervisor.start_link
