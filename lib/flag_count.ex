defmodule Bonfire.Data.Social.FlagCount do

  use Pointers.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_flag_count"

  alias Bonfire.Data.Social.FlagCount
  alias Ecto.Changeset

  mixin_schema do
    field :flag_count, :integer, default: 0
    field :flagger_count, :integer, default: 0
  end

  @cast [:flag_count, :flagger_count]

  def changeset(fc \\ %FlagCount{}, params) do
    Changeset.cast(fc, params, @cast)
  end

end
defmodule Bonfire.Data.Social.FlagCount.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.FlagCount

  @flag_count_table FlagCount.__schema__(:source)

  # create_flag_count_table/{0,1}

  defp make_flag_count_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_mixin_table(Bonfire.Data.Social.FlagCount) do
        Ecto.Migration.add :flag_count, :bigint, null: false, default: 0
        Ecto.Migration.add :flagger_count, :bigint, null: false, default: 0
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_flag_count_table(), do: make_flag_count_table([])
  defmacro create_flag_count_table([do: {_, _, body}]), do: make_flag_count_table(body)

  # drop_flag_count_table/0

  def drop_flag_count_table(), do: drop_mixin_table(FlagCount)

  # create_flag_count_index/{0, 1}

  defp make_flag_count_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@flag_count_table), [:flag_count], unquote(opts))
      )
    end
  end

  defmacro create_flag_count_index(opts \\ [])
  defmacro create_flag_count_index(opts), do: make_flag_count_index(opts)

  def drop_flag_count_index(opts \\ []) do
    drop_if_exists(index(@flag_count_table, [:flag_count], opts))
  end

  # create_flagger_count_index/{0, 1}

  defp make_flagger_count_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@flag_count_table), [:flagger_count], unquote(opts))
      )
    end
  end

  defmacro create_flagger_count_index(opts \\ [])
  defmacro create_flagger_count_index(opts), do: make_flagger_count_index(opts)

  def drop_flagger_count_index(opts \\ []) do
    drop_if_exists(index(@flag_count_table, [:flagger_count], opts))
  end


  # migrate_flag_count/{0,1}

  defp mlc(:up) do
    quote do
      unquote(make_flag_count_table([]))
      unquote(make_flag_count_index([]))
    end
  end
  defp mlc(:down) do
    quote do
      Bonfire.Data.Social.FlagCount.Migration.drop_flag_count_index()
      Bonfire.Data.Social.FlagCount.Migration.drop_flag_count_table()
    end
  end

  defmacro migrate_flag_count() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mlc(:up)),
        else: unquote(mlc(:down))
    end
  end
  defmacro migrate_flag_count(dir), do: mlc(dir)

end
