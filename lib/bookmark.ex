defmodule Bonfire.Data.Social.Bookmark do

  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "0EMEMBERS0METH1NGSF0R1ATER",
    source: "bonfire_data_social_bookmark"

  alias Bonfire.Data.Social.Bookmark
  alias Ecto.Changeset
  alias Pointers.Pointer

  virtual_schema do
  end

  def changeset(bookmark \\ %Bookmark{}, params) do
    bookmark
    |> Changeset.cast(params, [])
  end

end
defmodule Bonfire.Data.Social.Bookmark.Migration do

  import Pointers.Migration
  alias Bonfire.Data.Social.Bookmark
  import Bonfire.Data.Edges.Edge.Migration
  import Bonfire.Data.Edges.EdgeTotal.Migration

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
