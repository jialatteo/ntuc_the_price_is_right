defmodule NtucPriceIsRightWeb.LeaderboardLive do
  use NtucPriceIsRightWeb, :live_view
  alias NtucPriceIsRight.TopScores

  def mount(_params, _session, socket) do
    top_scores = TopScores.list_top_scores()

    {:ok,
     socket
     |> assign(:top_scores, top_scores)}
  end

  def render(assigns) do
    ~H"""
    <h1 class="font-bold text-3xl mb-8 ml-4 sm:ml-0">Leaderboard</h1>

    <.table table_class="w-full" id="submissions" rows={Enum.with_index(@top_scores, 1)}>
      <:col :let={{score_record, index}} label="Rank">
        #{index}
      </:col>
      
      <:col :let={{score_record, _index}} label="User">
        {score_record.user}
      </:col>
      
      <:col :let={{score_record, _index}} label="Score">
        {score_record.score}
      </:col>
      
      <:col :let={{score_record, _index}} label="Created at">
        {score_record.inserted_at
        # Convert it to a DateTime in UTC
        |> Timex.to_datetime("UTC")
        # Convert to GMT+8 (Singapore Time)
        |> Timex.Timezone.convert("Asia/Singapore")
        # Format the DateTime to a readable string
        |> Timex.format!("%d %b %y, %-I:%M %p", :strftime)}
      </:col>
    </.table>
    """
  end
end
