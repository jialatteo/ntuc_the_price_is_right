defmodule NtucPriceIsRight.TopScores.TopScore do
  use Ecto.Schema
  import Ecto.Changeset

  schema "top_scores" do
    field :user, :string
    field :score, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(top_score, attrs) do
    top_score
    |> cast(attrs, [:user, :score])
    |> validate_required([:user, :score])
    |> validate_length(:user, max: 20)
  end
end
