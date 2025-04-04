defmodule Matchmaker do
  use GenServer
  alias Phoenix.PubSub
  @pubsub NtucPriceIsRight.PubSub

  ### State Structure ###
  # %{
  #   waiting: nil | pid,
  #   active_games: [
  #     %{game_id: "uuid", players: [pid1, pid2]}
  #   ]
  # }

  # Public API

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  def join_queue(pid), do: GenServer.call(__MODULE__, {:join_queue, pid})
  def leave_queue(pid), do: GenServer.cast(__MODULE__, {:leave_queue, pid})
  def end_game(game_id), do: GenServer.cast(__MODULE__, {:end_game, game_id})

  # GenServer callbacks

  def init(_) do
    {:ok, %{waiting: nil, active_games: []}}
  end

  def handle_call({:join_queue, pid}, _from, %{waiting: nil} = state) do
    {:reply, :waiting, %{state | waiting: pid}}
  end

  def handle_call({:join_queue, pid2}, _from, %{waiting: pid1} = state) do
    game_id = UUID.uuid4()
    players = [pid1, pid2]

    Enum.each(players, fn pid ->
      send(pid, {:matched, %{game_id: game_id}})
    end)

    new_state = %{
      state
      | waiting: nil,
        active_games: [%{game_id: game_id, players: players} | state.active_games]
    }

    {:reply, {:matched, game_id}, new_state}
  end

  def handle_cast({:leave_queue, pid}, state) do
    case state.waiting do
      ^pid -> {:noreply, %{state | waiting: nil}}
      _ -> {:noreply, state}
    end
  end

  def handle_cast({:end_game, game_id}, state) do
    games = Enum.reject(state.active_games, fn g -> g.game_id == game_id end)
    {:noreply, %{state | active_games: games}}
  end
end
