defmodule Bonfire.Data.Social.Block do

  use Pointers.Pointable,
    otp_app: :bonfire_data_social,
    table_id: "B10CK1NGSTVFFAV01DSSEE1NG1",
    source: "bonfire_data_social_block"

  require Pointers.Changesets
  alias Bonfire.Data.Social.Block
  alias Ecto.Changeset
  alias Pointers.Pointer
  
  pointable_schema do
    belongs_to :blocker, Pointer
    belongs_to :blocked, Pointer
  end

  @cast     [:blocker_id, :blocked_id]
  @required @cast

  def changeset(block \\ %Block{}, params) do
    block
    |> Changeset.cast(params, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.assoc_constraint(:blocker)
    |> Changeset.assoc_constraint(:blocked)
  end

end
defmodule Bonfire.Data.Social.Block.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Block

  @block_table Block.__schema__(:source)
  @unique_index [:blocker_id, :blocked_id]

  # create_block_table/{0,1}

  defp make_block_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.Social.Block) do
        Ecto.Migration.add :blocker_id, Pointers.Migration.strong_pointer(), null: false
        Ecto.Migration.add :blocked_id, Pointers.Migration.strong_pointer(), null: false
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_block_table(), do: make_block_table([])
  defmacro create_block_table([do: {_, _, body}]), do: make_block_table(body)

  # drop_block_table/0

  def drop_block_table(), do: drop_pointable_table(Block)

  # create_block_unique_index/{0,1}

  defp make_block_unique_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.unique_index(unquote(@block_table), unquote(@unique_index), unquote(opts))
      )
    end
  end

  defmacro create_block_unique_index(opts \\ [])
  defmacro create_block_unique_index(opts), do: make_block_unique_index(opts)

  def drop_block_unique_index(opts \\ [])
  def drop_block_unique_index(opts), do: drop_if_exists(unique_index(@block_table, @unique_index, opts))

  defp make_block_blocked_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@block_table), [:blocked_id], unquote(opts))
      )
    end
  end

  defmacro create_block_blocked_index(opts \\ [])
  defmacro create_block_blocked_index(opts), do: make_block_blocked_index(opts)

  def drop_block_blocked_index(opts \\ []) do
    drop_if_exists(index(@block_table, [:blocked_id], opts))
  end

  # migrate_block/{0,1}

  defp mf(:up) do
    quote do
      unquote(make_block_table([]))
      unquote(make_block_unique_index([]))
      unquote(make_block_blocked_index([]))
    end
  end
  defp mf(:down) do
    quote do
      Bonfire.Data.Social.Block.Migration.drop_block_blocked_index()
      Bonfire.Data.Social.Block.Migration.drop_block_unique_index()
      Bonfire.Data.Social.Block.Migration.drop_block_table()
    end
  end

  defmacro migrate_block() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mf(:up)),
        else: unquote(mf(:down))
    end
  end

  defmacro migrate_block(dir), do: mf(dir)

end
