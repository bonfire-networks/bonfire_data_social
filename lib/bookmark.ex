defmodule Bonfire.Data.Social.Bookmark do

  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "0EMEMBERS0METH1NGSF0R1ATER",
    source: "bonfire_data_social_bookmark"

  alias Bonfire.Data.Social.Bookmark
  alias Bonfire.Data.Edges.Edge
  alias Ecto.Changeset
  alias Pointers.Pointer

  virtual_schema do
    has_one :edge, Edge, foreign_key: :id
  end

  def changeset(bookmark \\ %Bookmark{}, params)

  def changeset(bookmark, %{edge: edge}), do:
    bookmark
    |> Changeset.cast(%{edge: Map.merge(edge, %{table_id: "0EMEMBERS0METH1NGSF0R1ATER"})}, [])

  def changeset(bookmark, params), do:
    bookmark
    |> Changeset.cast(params, [])

end
defmodule Bonfire.Data.Social.Bookmark.Migration do

  import Ecto.Migration
  import Pointers.Migration
  import Bonfire.Data.Edges.Edge.Migration
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
