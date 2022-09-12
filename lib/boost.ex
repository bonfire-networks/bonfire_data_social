defmodule Bonfire.Data.Social.Boost do
  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "300STANN0VNCERESHARESH0VTS",
    source: "bonfire_data_social_boost"

  alias Bonfire.Data.Edges.Edge
  alias Bonfire.Data.Social.Boost
  alias Pointers.Changesets

  virtual_schema do
    has_one(:edge, Edge, foreign_key: :id)
  end

  def changeset(boost \\ %Boost{}, params),
    do: Changesets.cast(boost, params, [])
end

defmodule Bonfire.Data.Social.Boost.Migration do
  import Ecto.Migration
  import Pointers.Migration
  import Bonfire.Data.Edges.EdgeTotal.Migration
  alias Bonfire.Data.Social.Boost

  def migrate_boost_view(), do: migrate_virtual(Boost)

  def migrate_boost_total_view(), do: migrate_edge_total_view(Boost)

  def migrate_boost(dir \\ direction())

  def migrate_boost(:up) do
    migrate_boost_view()
    migrate_boost_total_view()
  end

  def migrate_boost(:down) do
    migrate_boost_total_view()
    migrate_boost_view()
  end
end
