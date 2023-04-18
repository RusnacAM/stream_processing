defmodule ReaderSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      Supervisor.child_spec({PrinterSupervisor, {3, RedactedText}}, id: :redactedprinters),
      Supervisor.child_spec({PrinterSupervisor, {3, EngagementRatio}}, id: :engagementprinters),
      Supervisor.child_spec({PrinterSupervisor, {3, SentimentScore}}, id: :sentimentprinters),
      Supervisor.child_spec({UserEngagement, []}, id: :userengagement),
      Supervisor.child_spec({Aggregator, []}, id: :aggregator),
      Supervisor.child_spec({HashtagPrinter, []}, id: :hashtagprinter),
      Supervisor.child_spec({EmotionReader, ["http://localhost:4000/emotion_values"]}, id: :emotionvalues),
      Supervisor.child_spec({Mediator, 3}, id: :loadbalancer),
      Supervisor.child_spec({Batcher, {150, 1500}}, id: :batcher),
      Supervisor.child_spec({Database, []}, id: :localdb),
      Supervisor.child_spec({SseReader, ["http://localhost:4000/tweets/1"]}, id: :tweets1),
      Supervisor.child_spec({SseReader, ["http://localhost:4000/tweets/2"]}, id: :tweets2)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def get_pid(id) do
    Supervisor.which_children(__MODULE__)
    |> Enum.find(fn {i, _, _, _} -> i == id end)
    |> elem(1)
  end
end

# {:ok, pid} = ReaderSupervisor.start_link
# red = ReaderSupervisor.get_pid(:redactedprinters)
