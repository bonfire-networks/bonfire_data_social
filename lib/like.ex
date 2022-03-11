defmodule Bonfire.Data.Social.Like do

  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "11KES11KET0BE11KEDY0VKN0WS",
    source: "bonfire_data_social_like"

  alias Pointers.Changesets
  alias Bonfire.Data.Social.Like
  alias Bonfire.Data.Edges.Edge
  alias Ecto.Changeset
  alias Pointers.Pointer

  virtual_schema do
    has_one :edge, Edge, foreign_key: :id
  end

  def changeset(like \\ %Like{}, params)

  def changeset(like, params) do
    like
    |> Changeset.put_assoc(:edge, %{table_id: __pointers__(:table_id)})
    |> Changeset.cast_assoc(:edge)
  end

end
defmodule Bonfire.Data.Social.Like.Migration do

  import Ecto.Migration
  import Pointers.Migration
  import Bonfire.Data.Edges.Edge.Migration
  import Bonfire.Data.Edges.EdgeTotal.Migration
  alias Bonfire.Data.Social.Like

  def migrate_like_view(), do: migrate_virtual(Like)

  def migrate_like_unique_index(), do: migrate_type_unique_index(Like)

  def migrate_like_total_view(), do: migrate_edge_total_view(Like)

  def migrate_like(dir \\ direction())

  def migrate_like(:up) do
    migrate_like_view()
    migrate_like_unique_index()
    migrate_like_total_view()
  end

  def migrate_like(:down) do
    migrate_like_total_view()
    migrate_like_unique_index()
    migrate_like_view()
  end

end
