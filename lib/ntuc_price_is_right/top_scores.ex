defmodule NtucPriceIsRight.TopScores do
  @moduledoc """
  The TopScores context.
  """

  import Ecto.Query, warn: false
  alias NtucPriceIsRight.Repo

  alias NtucPriceIsRight.TopScores.TopScore

  @limit 10

  def qualifies_for_top_score?(score) do
    count = Repo.aggregate(TopScore, :count, :id)

    cond do
      count < @limit ->
        true

      true ->
        # Get the 10th place score (lowest in top 10)
        last_place =
          TopScore
          |> order_by([s], desc: s.score, asc: s.inserted_at)
          |> limit(@limit)
          |> Repo.all()
          |> List.last()

        score > last_place.score
    end
  end

  def insert_top_score!(attrs) do
    new_score = %TopScore{
      user: attrs["user"],
      score: attrs["score"]
    }

    Repo.transaction(fn ->
      # Insert the new score
      Repo.insert!(new_score)

      # Get top 11 scores, ordered with tie-breaker logic
      top_scores =
        TopScore
        |> order_by([s], desc: s.score, asc: s.inserted_at)
        |> limit(@limit + 1)
        |> Repo.all()

      # If we now have 11, delete the lowest (last in sorted list)
      if length(top_scores) > @limit do
        to_delete = List.last(top_scores)
        Repo.delete!(to_delete)
      end
    end)
  end

  def rename_user(old_name, new_name) do
    TopScore
    |> where([s], s.user == ^old_name)
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}

      top_score ->
        top_score
        |> TopScore.changeset(%{user: new_name})
        |> Repo.update()
    end
  end

  def list_top_scores do
    TopScore
    |> order_by([s], desc: s.score, asc: s.inserted_at)
    |> limit(@limit)
    |> Repo.all()
  end

  @doc """
  Returns the list of top_scores.

  ## Examples

      iex> list_top_scores()
      [%TopScore{}, ...]

  """
  def list_top_scores do
    Repo.all(TopScore)
  end

  @doc """
  Gets a single top_score.

  Raises `Ecto.NoResultsError` if the Top score does not exist.

  ## Examples

      iex> get_top_score!(123)
      %TopScore{}

      iex> get_top_score!(456)
      ** (Ecto.NoResultsError)

  """
  def get_top_score!(id), do: Repo.get!(TopScore, id)

  @doc """
  Creates a top_score.

  ## Examples

      iex> create_top_score(%{field: value})
      {:ok, %TopScore{}}

      iex> create_top_score(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_top_score(attrs \\ %{}) do
    %TopScore{}
    |> TopScore.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a top_score.

  ## Examples

      iex> update_top_score(top_score, %{field: new_value})
      {:ok, %TopScore{}}

      iex> update_top_score(top_score, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_top_score(%TopScore{} = top_score, attrs) do
    top_score
    |> TopScore.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a top_score.

  ## Examples

      iex> delete_top_score(top_score)
      {:ok, %TopScore{}}

      iex> delete_top_score(top_score)
      {:error, %Ecto.Changeset{}}

  """
  def delete_top_score(%TopScore{} = top_score) do
    Repo.delete(top_score)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking top_score changes.

  ## Examples

      iex> change_top_score(top_score)
      %Ecto.Changeset{data: %TopScore{}}

  """
  def change_top_score(%TopScore{} = top_score, attrs \\ %{}) do
    TopScore.changeset(top_score, attrs)
  end
end
