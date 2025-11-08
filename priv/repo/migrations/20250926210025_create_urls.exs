defmodule Expire.Repo.Migrations.CreateUrls do
  use Ecto.Migration

  def change do
    create table(:urls) do
      add :short, :string
      add :long, :string
      add :expire_at, :utc_datetime
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:urls, [:user_id])
    create unique_index(:urls, [:short])
  end
end
