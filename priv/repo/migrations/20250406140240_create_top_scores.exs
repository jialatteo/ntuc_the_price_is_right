defmodule NtucPriceIsRight.Repo.Migrations.CreateTopScores do
  use Ecto.Migration

  def change do
    create table(:top_scores) do
      add :user, :string
      add :score, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
