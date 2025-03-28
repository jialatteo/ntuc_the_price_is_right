defmodule NtucScraper.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :title, :string
      add :price, :float
      add :image, :string
      add :quantity, :string

      timestamps(type: :utc_datetime)
    end

  end
end
