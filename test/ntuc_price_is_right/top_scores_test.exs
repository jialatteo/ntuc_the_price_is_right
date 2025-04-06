defmodule NtucPriceIsRight.TopScoresTest do
  use NtucPriceIsRight.DataCase

  alias NtucPriceIsRight.TopScores

  describe "top_scores" do
    alias NtucPriceIsRight.TopScores.TopScore

    import NtucPriceIsRight.TopScoresFixtures

    @invalid_attrs %{user: nil, score: nil}

    test "list_top_scores/0 returns all top_scores" do
      top_score = top_score_fixture()
      assert TopScores.list_top_scores() == [top_score]
    end

    test "get_top_score!/1 returns the top_score with given id" do
      top_score = top_score_fixture()
      assert TopScores.get_top_score!(top_score.id) == top_score
    end

    test "create_top_score/1 with valid data creates a top_score" do
      valid_attrs = %{user: "some user", score: 42}

      assert {:ok, %TopScore{} = top_score} = TopScores.create_top_score(valid_attrs)
      assert top_score.user == "some user"
      assert top_score.score == 42
    end

    test "create_top_score/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TopScores.create_top_score(@invalid_attrs)
    end

    test "update_top_score/2 with valid data updates the top_score" do
      top_score = top_score_fixture()
      update_attrs = %{user: "some updated user", score: 43}

      assert {:ok, %TopScore{} = top_score} = TopScores.update_top_score(top_score, update_attrs)
      assert top_score.user == "some updated user"
      assert top_score.score == 43
    end

    test "update_top_score/2 with invalid data returns error changeset" do
      top_score = top_score_fixture()
      assert {:error, %Ecto.Changeset{}} = TopScores.update_top_score(top_score, @invalid_attrs)
      assert top_score == TopScores.get_top_score!(top_score.id)
    end

    test "delete_top_score/1 deletes the top_score" do
      top_score = top_score_fixture()
      assert {:ok, %TopScore{}} = TopScores.delete_top_score(top_score)
      assert_raise Ecto.NoResultsError, fn -> TopScores.get_top_score!(top_score.id) end
    end

    test "change_top_score/1 returns a top_score changeset" do
      top_score = top_score_fixture()
      assert %Ecto.Changeset{} = TopScores.change_top_score(top_score)
    end
  end
end
