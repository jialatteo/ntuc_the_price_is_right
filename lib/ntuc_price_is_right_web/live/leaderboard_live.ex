defmodule NtucPriceIsRightWeb.LeaderboardLive do
  use NtucPriceIsRightWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <p>leaderboard</p>
    """
  end
end
