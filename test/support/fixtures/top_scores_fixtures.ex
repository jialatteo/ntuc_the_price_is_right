defmodule NtucPriceIsRight.TopScoresFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `NtucPriceIsRight.TopScores` context.
  """

  @doc """
  Generate a top_score.
  """
  def top_score_fixture(attrs \\ %{}) do
    {:ok, top_score} =
      attrs
      |> Enum.into(%{
        score: 42,
        user: "some user"
      })
      |> NtucPriceIsRight.TopScores.create_top_score()

    top_score
  end
end
