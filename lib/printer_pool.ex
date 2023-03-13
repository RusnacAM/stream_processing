defmodule PrinterPool do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      %{
        id: :printer1,
        start: {Printer, :start_link, []}
      },
      %{
        id: :printer2,
        start: {Printer, :start_link, []}
      },
      %{
        id: :printer3,
        start: {Printer, :start_link, []}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
