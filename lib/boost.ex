defmodule Bonfire.Data.Social.Boost do

  use Pointers.Pointable,
    otp_app: :bonfire_data_social,
    table_id: "B00STANN0VNCERESHARESH0VTS",
    source: "bonfire_data_social_boost"

  require Pointers.Changesets
  alias Bonfire.Data.Social.Boost
  alias Ecto.Changeset
  alias Pointers.Pointer

  pointable_schema do
    belongs_to :booster, Pointer
    belongs_to :boosted, Pointer
  end

  @cast     [:booster_id, :boosted_id]
  @required [:booster_id, :boosted_id]

  def changeset(boost \\ %Boost{}, params) do
    boost
    |> Changeset.cast(params, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.assoc_constraint(:booster)
    |> Changeset.assoc_constraint(:boosted)
    |> Changeset.unique_constraint([:booster_id, :boosted_id])
  end

end
defmodule Bonfire.Data.Social.Boost.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Boost

  @boost_table Boost.__schema__(:source)
  @unique_index [:booster_id, :boosted_id]

  # create_boost_table/{0,1}

  defp make_boost_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.Social.Boost) do
        Ecto.Migration.add :booster_id,
          Pointers.Migration.strong_pointer(), null: false
        Ecto.Migration.add :boosted_id,
          Pointers.Migration.strong_pointer(), null: false
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_boost_table(), do: make_boost_table([])
  defmacro create_boost_table([do: {_, _, body}]), do: make_boost_table(body)

  # drop_boost_table/0

  def drop_boost_table(), do: drop_pointable_table(Boost)

  # create_boost_unique_index/{0,1}

  defp make_boost_unique_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.unique_index(unquote(@boost_table), unquote(@unique_index), unquote(opts))
      )
    end
  end

  defmacro create_boost_unique_index(opts \\ [])
  defmacro create_boost_unique_index(opts), do: make_boost_unique_index(opts)

  def drop_boost_unique_index(opts \\ [])
  def drop_boost_unique_index(opts), do: drop_if_exists(unique_index(@boost_table, @unique_index, opts))

  defp make_boost_boosted_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@boost_table), [:boosted_id], unquote(opts))
      )
    end
  end

  defmacro create_boost_boosted_index(opts \\ [])
  defmacro create_boost_boosted_index(opts), do: make_boost_boosted_index(opts)

  def drop_boost_boosted_index(opts \\ []) do
    drop_if_exists(index(@boost_table, [:boosted_id], opts))
  end

  # migrate_boost/{0,1}

  defp ml(:up) do
    quote do
      unquote(make_boost_table([]))
      unquote(make_boost_unique_index([]))
      unquote(make_boost_boosted_index([]))
    end
  end
  defp ml(:down) do
    quote do
      Bonfire.Data.Social.Boost.Migration.drop_boost_boosted_index()
      Bonfire.Data.Social.Boost.Migration.drop_boost_unique_index()
      Bonfire.Data.Social.Boost.Migration.drop_boost_table()
    end
  end

  defmacro migrate_boost() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(ml(:up)),
        else: unquote(ml(:down))
    end
  end

  defmacro migrate_boost(dir), do: ml(dir)

end
