defmodule MyAppWeb.MatchmakingChannel do
  use Phoenix.Channel

  def join("matchmaking:lobby", _payload, socket) do
    Matchmaker.join_queue(self())
    {:ok, socket}
  end

  def terminate(_reason, socket) do
    Matchmaker.leave_queue(self())
    :ok
  end

  def handle_info({:matched, %{game_id: game_id}}, socket) do
    push(socket, "matched", %{game_id: game_id})
    {:noreply, socket}
  end
end
