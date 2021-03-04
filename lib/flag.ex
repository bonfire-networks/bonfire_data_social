defmodule Bonfire.Data.Social.Flag do

  use Pointers.Pointable,
    otp_app: :bonfire_data_social,
    table_id: "F1AGSPAM0RVNACCEPTAB1E1TEM",
    source: "bonfire_data_social_flag"

  require Pointers.Changesets
  alias Bonfire.Data.Social.Flag
  alias Ecto.Changeset
  alias Pointers.{Changesets, Pointer}

  pointable_schema do
    belongs_to :flagger, Pointer
    belongs_to :flagged, Pointer
  end

  @cast     [:flagger_id, :flagged_id]
  @required [:flagger_id, :flagged_id]

  def changeset(flag \\ %Flag{}, params) do
    flag
    |> Changeset.cast(params, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.assoc_constraint(:flagger)
    |> Changeset.assoc_constraint(:flagged)
    |> Changeset.unique_constraint([:flagger_id, :flagged_id])
  end

end
defmodule Bonfire.Data.Social.Flag.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Flag

  @flag_table Flag.__schema__(:source)
  @unique_index [:flagger_id, :flagged_id]

  # create_flag_table/{0,1}

  defp make_flag_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.Social.Flag) do
        Ecto.Migration.add :flagger_id,
          Pointers.Migration.strong_pointer(), null: false
        Ecto.Migration.add :flagged_id,
          Pointers.Migration.strong_pointer(), null: false
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_flag_table(), do: make_flag_table([])
  defmacro create_flag_table([do: {_, _, body}]), do: make_flag_table(body)

  # drop_flag_table/0

  def drop_flag_table(), do: drop_pointable_table(Flag)

  # create_flag_unique_index/{0,1}

  defp make_flag_unique_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.unique_index(unquote(@flag_table), unquote(@unique_index), unquote(opts))
      )
    end
  end

  defmacro create_flag_unique_index(opts \\ [])
  defmacro create_flag_unique_index(opts), do: make_flag_unique_index(opts)

  def drop_flag_unique_index(opts \\ [])
  def drop_flag_unique_index(opts), do: drop_if_exists(unique_index(@flag_table, @unique_index, opts))

  defp make_flag_flagged_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@flag_table), [:flagged_id], unquote(opts))
      )
    end
  end

  defmacro create_flag_flagged_index(opts \\ [])
  defmacro create_flag_flagged_index(opts), do: make_flag_flagged_index(opts)

  def drop_flag_flagged_index(opts \\ []) do
    drop_if_exists(index(@flag_table, [:flagged_id], opts))
  end

  # migrate_flag/{0,1}

  defp ml(:up) do
    quote do
      unquote(make_flag_table([]))
      unquote(make_flag_unique_index([]))
      unquote(make_flag_flagged_index([]))
    end
  end
  defp ml(:down) do
    quote do
      Bonfire.Data.Social.Flag.Migration.drop_flag_flagged_index()
      Bonfire.Data.Social.Flag.Migration.drop_flag_unique_index()
      Bonfire.Data.Social.Flag.Migration.drop_flag_table()
    end
  end

  defmacro migrate_flag() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(ml(:up)),
        else: unquote(ml(:down))
    end
  end

  defmacro migrate_flag(dir), do: ml(dir)

end
