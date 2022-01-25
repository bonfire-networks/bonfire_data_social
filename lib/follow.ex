defmodule Bonfire.Data.Social.Follow do

  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "70110WTHE1EADER1EADER1EADE",
    source: "bonfire_data_social_follow"

  require Pointers.Changesets
  alias Bonfire.Data.Social.Follow
  alias Bonfire.Data.Edges.Edge
  alias Ecto.Changeset

  virtual_schema do
    has_one :edge, Edge, foreign_key: :id
  end

  def changeset(follow \\ %Follow{}, params)

  def changeset(follow, params) do
    # edge needs this to enforce uniqueness. we don't expect it to be nil.
    params = Map.update(params, :edge, nil, &Map.put(&1, :table_id, "70110WTHE1EADER1EADER1EADE"))
    follow
    |> Changeset.cast(params, [])
  end

end
defmodule Bonfire.Data.Social.Follow.Migration do

  import Ecto.Migration
  import Pointers.Migration
  import Bonfire.Data.Edges.Edge.Migration
  import Bonfire.Data.Edges.EdgeTotal.Migration
  alias Bonfire.Data.Social.Follow

  def migrate_follow_view(), do: migrate_virtual(Follow)

  def migrate_follow_unique_index(), do: migrate_type_unique_index(Follow)

  def migrate_follow_total_view(), do: migrate_edge_total_view(Follow)

  def migrate_follow(dir \\ direction())

  def migrate_follow(:up) do
    migrate_follow_view()
    migrate_follow_unique_index()
    migrate_follow_total_view()
  end

  def migrate_follow(:down) do
    migrate_follow_total_view()
    migrate_follow_unique_index()
    migrate_follow_view()
  end

end
