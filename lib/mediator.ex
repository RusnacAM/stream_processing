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
    tweet_text = tweet_data["text"]

    call_redacted(curr_printer_num, tweet_text)
    call_engagement(curr_printer_num, tweet_data)
    call_sentiment(curr_printer_num, tweet_text)
    {:noreply, {total_printers, rem(curr_printer_num, total_printers)}}
  end

  def call_redacted(curr_printer_num, tweet_text) do
    redacted_printer = String.to_atom("RedactedText#{curr_printer_num}")
    redacted_sup_pid = ReaderSupervisor.get_pid(:redactedprinters)
    redacted_printer_pid = PrinterSupervisor.get_pid(curr_printer_num, redacted_sup_pid)
    RedactedText.censor_tweet(redacted_printer_pid, tweet_text)
  end

  def call_engagement(curr_printer_num, tweet_data) do
    engagement_printer = String.to_atom("EngagementRatio#{curr_printer_num}")
    engagement_sup_pid = ReaderSupervisor.get_pid(:engagementprinters)
    engagement_printer_pid = PrinterSupervisor.get_pid(curr_printer_num, engagement_sup_pid)
    EngagementRatio.get_engagement(engagement_printer_pid, tweet_data)
  end

  def call_sentiment(curr_printer_num, tweet_text) do
    sentiment_printer = String.to_atom("SentimentScore#{curr_printer_num}")
    sentiment_sup_pid = ReaderSupervisor.get_pid(:sentimentprinters)
    sentiment_printer_pid = PrinterSupervisor.get_pid(curr_printer_num, sentiment_sup_pid)
    SentimentScore.get_sentiment(sentiment_printer_pid, tweet_text)
  end

end

# Mediator.start_link(3)
# Mediator.redirect_text("fajef")
# {:ok, pid} = PrinterSupervisor.start_link
