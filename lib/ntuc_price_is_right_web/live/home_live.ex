defmodule NtucPriceIsRightWeb.HomeLive do
  use NtucPriceIsRightWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col gap-8 items-center justify-center py-8">
      <a class="text-4xl rounded p-4 bg-blue-100 hover:bg-blue-300" href="/single-player">
        Single player mode
      </a>
      
      <a class="text-4xl rounded p-4 bg-blue-100 hover:bg-blue-300" href="/multi-player">
        Multi player mode
      </a>
      
      <a class="text-4xl rounded p-4 bg-blue-100 hover:bg-blue-300" href="/leaderboard">
        Leaderboard
      </a>
    </div>
    """
  end
end
