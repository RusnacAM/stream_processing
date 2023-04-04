defmodule PrinterSupervisor do
  use Supervisor
  require Logger

  def start_link(state) do
    Logger.info("Starting Printer Supervisor.")
    Supervisor.start_link(__MODULE__, state)
  end

  def init({worker_num, module}) do

    children =
      for i <- 1..worker_num,
        do: %{
          id: String.to_atom("#{module}#{i}"),
          start: {module, :start_link, [String.to_atom("#{module}#{i}")]}
        }

    Supervisor.init(children, strategy: :one_for_one,  max_restarts: 100, max_seconds: 10000)
  end

  def get_pid(atom, id) when is_atom(atom) do
    Supervisor.which_children(id)
    |> Enum.find(fn {i, _, _, _} -> i == atom end)
    |> elem(1)
  end

  def get_pid(int, pid) when is_integer(int) do
    Supervisor.which_children(pid)
    |> Enum.at(int - 1)
    |> elem(1)
  end

end

# {:ok, redacted_sup} = PrinterSupervisor.start_link({3, RedactedText})
# Mediator.redirect_text(lb_redacted, "farygfa")
# PrinterSupervisor.get_pid(0, redacted_sup)
