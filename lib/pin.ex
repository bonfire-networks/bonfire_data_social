defmodule Bonfire.Data.Social.Pin do
  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "1P1NS0METH1NGT0H1GH11GHT1T",
    source: "bonfire_data_social_pin"

  alias Bonfire.Data.Edges.Edge
  alias Bonfire.Data.Social.Pin
  alias Pointers.Changesets

  virtual_schema do
    has_one(:edge, Edge, foreign_key: :id)
  end

  def changeset(pin \\ %Pin{}, params), do: Changesets.cast(pin, params, [])
end

defmodule Bonfire.Data.Social.Pin.Migration do
  @moduledoc false
  import Ecto.Migration
  import Pointers.Migration
  import Bonfire.Data.Edges.Edge.Migration
  import Bonfire.Data.Edges.EdgeTotal.Migration
  alias Bonfire.Data.Social.Pin

  def migrate_pin_view(), do: migrate_virtual(Pin)

  def migrate_pin_unique_index(), do: migrate_type_unique_index(Pin)

  def migrate_pin_total_view(), do: migrate_edge_total_view(Pin)

  def migrate_pin(dir \\ direction())

  def migrate_pin(:up) do
    migrate_pin_view()
    migrate_pin_unique_index()
    migrate_pin_total_view()
  end

  def migrate_pin(:down) do
    migrate_pin_total_view()
    migrate_pin_unique_index()
    migrate_pin_view()
  end
end
