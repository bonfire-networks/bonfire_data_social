defmodule Bonfire.Data.Social.Seen do
  @moduledoc """
    Track seen/unseen (similar to read/unread, but only indicates that it was displayed in a feed or other listing for the user, not that they actually read it) status of things (usually an `Activity`)
  """
  use Needle.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "1A1READYSAW0RREADTH1STH1NG",
    source: "bonfire_data_social_seen"

  alias Bonfire.Data.Edges.Edge
  alias Bonfire.Data.Social.Seen
  alias Needle.Changesets

  virtual_schema do
    has_one(:edge, Edge, foreign_key: :id)
  end

  def changeset(seen \\ %Seen{}, params), do: Changesets.cast(seen, params, [])
end

defmodule Bonfire.Data.Social.Seen.Migration do
  @moduledoc false
  import Ecto.Migration
  import Needle.Migration
  import Bonfire.Data.Edges.Edge.Migration
  import Bonfire.Data.Edges.EdgeTotal.Migration
  alias Bonfire.Data.Social.Seen

  def migrate_seen_view(), do: migrate_virtual(Seen)

  def migrate_seen_unique_index(), do: migrate_type_unique_index(Seen)

  def migrate_seen_total_view(), do: migrate_edge_total_view(Seen)

  def migrate_seen(dir \\ direction())

  def migrate_seen(:up) do
    migrate_seen_view()
    migrate_seen_unique_index()
    migrate_seen_total_view()
  end

  def migrate_seen(:down) do
    migrate_seen_total_view()
    migrate_seen_unique_index()
    migrate_seen_view()
  end
end
