defmodule Bonfire.Data.Content do
  use Pointers.Mixin,
    otp_app: :bonfire_data_content,
    source: "bonfire_data_social_content"

  alias __MODULE__
  alias Pointers.Changesets

  mixin_schema do
    field :name, :string
    field :summary, :string
    field :content, :string
  end

  def changeset(content \\ %Content{}, attrs, opts \\ []),
    do: Changesets.auto(content, attrs, opts, [])
end

defmodule Bonfire.Data.Content.Migration do
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Content

  def migrate_content(dir \\ direction())

  def migrate_content(:up) do
    create_mixin_table(Content) do
      add :name, :text
      add :summary, :text
      add :content, :text
    end
  end

  def migrate_content(:down) do
    drop_mixin_table(Content)
  end
end
