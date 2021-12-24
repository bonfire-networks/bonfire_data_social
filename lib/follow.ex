defmodule Bonfire.Data.Social.Follow do

  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "70110WTHE1EADER1EADER1EADE",
    source: "bonfire_data_social_follow"

  require Pointers.Changesets
  alias Bonfire.Data.Social.Follow
  alias Ecto.Changeset

  virtual_schema do
  end

  def changeset(follow \\ %Follow{}, params), do: Changeset.cast(follow, params, [])

end
defmodule Bonfire.Data.Social.Follow.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Follow
  import Bonfire.Data.Edges.Edge.Migration

  def migrate_follow_view(), do: migrate_virtual(Follow)

  def migrate_follow_unique_index(), do: migrate_type_unique_index(Follow)

  def migrate_follow(dir \\ direction())

  def migrate_follow(:up) do
    migrate_follow_view()
    migrate_follow_unique_index()
  end

  def migrate_follow(:down) do
    migrate_follow_unique_index()
    migrate_follow_view()
  end

end
