defmodule Bonfire.Data.Social.Like do
  use Needle.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "11KES11KET0BE11KEDY0VKN0WS",
    source: "bonfire_data_social_like"

  alias Bonfire.Data.Edges.Edge
  alias Bonfire.Data.Social.Like
  alias Needle.Changesets

  virtual_schema do
    has_one(:edge, Edge, foreign_key: :id)
  end

  def changeset(like \\ %Like{}, params), do: Changesets.cast(like, params, [])
end

defmodule Bonfire.Data.Social.Like.Migration do
  @moduledoc false
  import Ecto.Migration
  import Needle.Migration
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
