defmodule Bonfire.Data.Social.BoostCount do

  use Pointers.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_boost_count"

  alias Bonfire.Data.Social.BoostCount
  alias Ecto.Changeset

  mixin_schema do
    field :boost_count, :integer, default: 0
    field :booster_count, :integer, default: 0
  end

  @cast [:boost_count, :booster_count]

  def changeset(fc \\ %BoostCount{}, params) do
    Changeset.cast(fc, params, @cast)
  end

end
defmodule Bonfire.Data.Social.BoostCount.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.BoostCount

  @boost_count_table BoostCount.__schema__(:source)

  # create_boost_count_table/{0,1}

  defp make_boost_count_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_mixin_table(Bonfire.Data.Social.BoostCount) do
        Ecto.Migration.add :boost_count, :bigint, null: false, default: 0
        Ecto.Migration.add :booster_count, :bigint, null: false, default: 0
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_boost_count_table(), do: make_boost_count_table([])
  defmacro create_boost_count_table([do: {_, _, body}]), do: make_boost_count_table(body)

  # drop_boost_count_table/0

  def drop_boost_count_table(), do: drop_mixin_table(BoostCount)

  # create_boost_count_index/{0, 1}

  defp make_boost_count_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@boost_count_table), [:boost_count], unquote(opts))
      )
    end
  end

  defmacro create_boost_count_index(opts \\ [])
  defmacro create_boost_count_index(opts), do: make_boost_count_index(opts)

  def drop_boost_count_index(opts \\ []) do
    drop_if_exists(index(@boost_count_table, [:boost_count], opts))
  end

  # create_booster_count_index/{0, 1}

  defp make_booster_count_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@boost_count_table), [:booster_count], unquote(opts))
      )
    end
  end

  defmacro create_booster_count_index(opts \\ [])
  defmacro create_booster_count_index(opts), do: make_booster_count_index(opts)

  def drop_booster_count_index(opts \\ []) do
    drop_if_exists(index(@boost_count_table, [:booster_count], opts))
  end


  # migrate_boost_count/{0,1}

  defp mlc(:up) do
    quote do
      unquote(make_boost_count_table([]))
      unquote(make_boost_count_index([]))
    end
  end
  defp mlc(:down) do
    quote do
      Bonfire.Data.Social.BoostCount.Migration.drop_boost_count_index()
      Bonfire.Data.Social.BoostCount.Migration.drop_boost_count_table()
    end
  end

  defmacro migrate_boost_count() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mlc(:up)),
        else: unquote(mlc(:down))
    end
  end
  defmacro migrate_boost_count(dir), do: mlc(dir)

end
