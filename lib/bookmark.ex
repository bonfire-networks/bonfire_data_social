defmodule Bonfire.Data.Social.Bookmark do
  use Needle.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "0EMEMBERS0METH1NGSF0R1ATER",
    source: "bonfire_data_social_bookmark"

  alias Bonfire.Data.Edges.Edge
  alias Bonfire.Data.Social.Bookmark
  alias Needle.Changesets

  virtual_schema do
    has_one(:edge, Edge, foreign_key: :id)
  end

  def changeset(bookmark \\ %Bookmark{}, params),
    do: Changesets.cast(bookmark, params, [])
end

defmodule Bonfire.Data.Social.Bookmark.Migration do
  @moduledoc false
  import Ecto.Migration
  import Needle.Migration
  import Bonfire.Data.Edges.EdgeTotal.Migration
  alias Bonfire.Data.Social.Bookmark

  def migrate_bookmark_view(), do: migrate_virtual(Bookmark)

  def migrate_bookmark_total_view(), do: migrate_edge_total_view(Bookmark)

  def migrate_bookmark(dir \\ direction())

  def migrate_bookmark(:up) do
    migrate_bookmark_view()
    migrate_bookmark_total_view()
  end

  def migrate_bookmark(:down) do
    migrate_bookmark_total_view()
    migrate_bookmark_view()
  end
end
