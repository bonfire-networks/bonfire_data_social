defmodule Bonfire.Data.Social.FollowCount do

  use Pointers.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_follow_count"

  alias Pointers.Changesets
  require Pointers.Changesets
  alias Bonfire.Data.Social.FollowCount
  
  mixin_schema do
    field :follow_count, :integer, default: 0
    field :follower_count, :integer, default: 0
  end

  @defaults [
    cast: [:follow_count, :follower_count],
  ]

  def changeset(fc \\ %FollowCount{}, attrs, opts \\ []) do
    Changesets.auto(fc, attrs, opts, @defaults)
  end

end
defmodule Bonfire.Data.Social.FollowCount.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.FollowCount

  @follow_count_table FollowCount.__schema__(:source)

  # create_follow_count_table/{0,1}

  defp make_follow_count_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_mixin_table(Bonfire.Data.Social.FollowCount) do
        Ecto.Migration.add :follow_count, :bigint, null: false, default: 0
        Ecto.Migration.add :follower_count, :bigint, null: false, default: 0
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_follow_count_table(), do: make_follow_count_table([])
  defmacro create_follow_count_table([do: {_, _, body}]), do: make_follow_count_table(body)

  # drop_follow_count_table/0

  def drop_follow_count_table(), do: drop_mixin_table(FollowCount)

  # create_follow_count_index/{0, 1}

  defp make_follow_count_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@follow_count_table), [:follow_count], unquote(opts))
      )
    end
  end

  defmacro create_follow_count_index(opts \\ [])
  defmacro create_follow_count_index(opts), do: make_follow_count_index(opts)

  def drop_follow_count_index(opts \\ []) do
    drop_if_exists(index(@follow_count_table, [:follow_count], opts))
  end

  # create_follower_count_index/{0, 1}

  defp make_follower_count_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@follow_count_table), [:follower_count], unquote(opts))
      )
    end
  end

  defmacro create_follower_count_index(opts \\ [])
  defmacro create_follower_count_index(opts), do: make_follower_count_index(opts)

  def drop_follower_count_index(opts \\ []) do
    drop_if_exists(index(@follow_count_table, [:follower_count], opts))
  end


  # migrate_follow_count/{0,1}

  defp mfc(:up) do
    quote do
      unquote(make_follow_count_table([]))
      unquote(make_follow_count_index([]))
    end      
  end
  defp mfc(:down) do
    quote do
      Bonfire.Data.Social.FollowCount.Migration.drop_follow_count_index()
      Bonfire.Data.Social.FollowCount.Migration.drop_follow_count_table()
    end
  end

  defmacro migrate_follow_count() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mfc(:up)),
        else: unquote(mfc(:down))
    end
  end
  defmacro migrate_follow_count(dir), do: mfc(dir)

end
