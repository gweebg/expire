defmodule Expire.Repo.Migrations.CreateClicks do
  use Ecto.Migration

  def change do
    create table(:clicks, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :ip, :string
      add :user_agent, :map
      add :geolocation, :map
      add :referrer, :string
      add :bot, :boolean

      add :url_id, references(:urls, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:clicks, [:url_id])
  end
end
