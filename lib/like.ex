defmodule Bonfire.Data.Social.Like do

  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "11KES11KET0BE11KEDY0VKN0WS",
    source: "bonfire_data_social_like"

  require Pointers.Changesets
  alias Bonfire.Data.Social.Like
  alias Ecto.Changeset
  alias Pointers.Pointer

  virtual_schema do
  end


  def changeset(like \\ %Like{}, params), do: Changeset.cast(like, params, [])

end
defmodule Bonfire.Data.Social.Like.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Like
  import Bonfire.Data.Edges.Edge.Migration

  def migrate_like_view(), do: migrate_virtual(Like)

  def migrate_like_unique_index(), do: migrate_type_unique_index(Like)

  def migrate_like(dir \\ direction())

  def migrate_like(:up) do
    migrate_like_view()
    migrate_like_unique_index()
  end

  def migrate_like(:down) do
    migrate_like_unique_index()
    migrate_like_view()
  end

end
