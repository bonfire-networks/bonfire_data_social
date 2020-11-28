defmodule Bonfire.Data.Social.LikeCount do

  use Pointers.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_like_count"

  alias Pointers.Changesets
  require Pointers.Changesets
  alias Bonfire.Data.Social.LikeCount
  
  mixin_schema do
    field :like_count, :integer, default: 0
    field :liker_count, :integer, default: 0
  end

  @defaults [
    cast: [:like_count, :liker_count],
  ]

  def changeset(fc \\ %LikeCount{}, attrs, opts \\ []) do
    Changesets.auto(fc, attrs, opts, @defaults)
  end

end
defmodule Bonfire.Data.Social.LikeCount.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.LikeCount

  @like_count_table LikeCount.__schema__(:source)

  # create_like_count_table/{0,1}

  defp make_like_count_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_mixin_table(Bonfire.Data.Social.LikeCount) do
        Ecto.Migration.add :like_count, :bigint, null: false, default: 0
        Ecto.Migration.add :liker_count, :bigint, null: false, default: 0
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_like_count_table(), do: make_like_count_table([])
  defmacro create_like_count_table([do: {_, _, body}]), do: make_like_count_table(body)

  # drop_like_count_table/0

  def drop_like_count_table(), do: drop_mixin_table(LikeCount)

  # create_like_count_index/{0, 1}

  defp make_like_count_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@like_count_table), [:like_count], unquote(opts))
      )
    end
  end

  defmacro create_like_count_index(opts \\ [])
  defmacro create_like_count_index(opts), do: make_like_count_index(opts)

  def drop_like_count_index(opts \\ []) do
    drop_if_exists(index(@like_count_table, [:like_count], opts))
  end

  # create_liker_count_index/{0, 1}

  defp make_liker_count_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@like_count_table), [:liker_count], unquote(opts))
      )
    end
  end

  defmacro create_liker_count_index(opts \\ [])
  defmacro create_liker_count_index(opts), do: make_liker_count_index(opts)

  def drop_liker_count_index(opts \\ []) do
    drop_if_exists(index(@like_count_table, [:liker_count], opts))
  end


  # migrate_like_count/{0,1}

  defp mfc(:up) do
    quote do
      unquote(make_like_count_table([]))
      unquote(make_like_count_index([]))
    end      
  end
  defp mfc(:down) do
    quote do
      Bonfire.Data.Social.LikeCount.Migration.drop_like_count_index()
      Bonfire.Data.Social.LikeCount.Migration.drop_like_count_table()
    end
  end

  defmacro migrate_like_count() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mfc(:up)),
        else: unquote(mfc(:down))
    end
  end
  defmacro migrate_like_count(dir), do: mfc(dir)

end
