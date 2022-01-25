defmodule Bonfire.Data.Social.Flag do

  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "71AGSPAM0RVNACCEPTAB1E1TEM",
    source: "bonfire_data_social_flag"

  require Pointers.Changesets
  alias Bonfire.Data.Social.Flag
  alias Bonfire.Data.Edges.Edge
  alias Ecto.Changeset

  virtual_schema do
    has_one :edge, Edge, foreign_key: :id
  end

  def changeset(flag \\ %Flag{}, params) do
    # edge needs this to enforce uniqueness. we don't expect it to be nil.
    params = Map.update(params, :edge, nil, &Map.put(&1, :table_id, "71AGSPAM0RVNACCEPTAB1E1TEM"))
    flag
    |> Changeset.cast(params, [])
  end

end
defmodule Bonfire.Data.Social.Flag.Migration do

  import Ecto.Migration
  import Pointers.Migration
  import Bonfire.Data.Edges.Edge.Migration
  import Bonfire.Data.Edges.EdgeTotal.Migration
  alias Bonfire.Data.Social.Flag

  def migrate_flag_view(), do: migrate_virtual(Flag)

  def migrate_flag_unique_index(), do: migrate_type_unique_index(Flag)

  def migrate_flag(dir \\ direction())

  def migrate_flag(:up) do
    migrate_flag_view()
    migrate_flag_unique_index()
  end

  def migrate_flag(:down) do
    migrate_flag_unique_index()
    migrate_flag_view()
  end

end
