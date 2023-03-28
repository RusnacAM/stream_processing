defmodule PrinterSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      %{
        id: :printer1,
        start: {Printer, :start_link, [:printer1]}
      },
      %{
        id: :printer2,
        start: {Printer, :start_link, [:printer2]}
      },
      %{
        id: :printer3,
        start: {Printer, :start_link, [:printer3]}
      },
    ]

    Supervisor.init(children, strategy: :one_for_one,  max_restarts: 100, max_seconds: 10000)
  end


  def get_pid(id) do
    Supervisor.which_children(__MODULE__)
    |> Enum.find(fn {i, _, _, _} -> i == id end)
    |> elem(1)
  end
end
