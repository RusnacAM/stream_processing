defmodule ReaderSupervisor do
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
      %{
        id: :loadbalancer,
        start: {Mediator, :start_link, [3]}
      },
      %{
        id: :hashtagprinter,
        start: {HashtagPrinter, :start_link, []}
      },
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
