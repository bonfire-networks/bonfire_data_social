defmodule Bonfire.Data.Social.Block do
  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "310CK1NGSTVFFAV01DSSEE1NG1",
    source: "bonfire_data_social_block"

  alias Bonfire.Data.Edges.Edge
  alias Bonfire.Data.Social.Block
  alias Pointers.Changesets

  virtual_schema do
    has_one(:edge, Edge, foreign_key: :id)
  end

  def changeset(block \\ %Block{}, params),
    do: Changesets.cast(block, params, [])
end

defmodule Bonfire.Data.Social.Block.Migration do
  @moduledoc false
  import Ecto.Migration
  import Pointers.Migration
  import Bonfire.Data.Edges.Edge.Migration
  alias Bonfire.Data.Social.Block

  def migrate_block_view(), do: migrate_virtual(Block)

  def migrate_block_unique_index(), do: migrate_type_unique_index(Block)

  def migrate_block(dir \\ direction())

  def migrate_block(:up) do
    migrate_block_view()
    migrate_block_unique_index()
  end

  def migrate_block(:down) do
    migrate_block_unique_index()
    migrate_block_view()
  end
end
