defmodule Bonfire.Data.Social.Like do

  use Pointers.Pointable,
    otp_app: :bonfire_data_social,
    table_id: "11KES11KET0BE11KEDY0VKN0WS",
    source: "bonfire_data_social_like"

  require Pointers.Changesets
  alias Bonfire.Data.Social.Like
  alias Ecto.Changeset
  alias Pointers.{Changesets, Pointer}
  
  pointable_schema do
    belongs_to :liker, Pointer
    belongs_to :liked, Pointer
  end

  @defaults [
    cast:     [:liker_id, :liked_id],
    required: [:liker_id, :liked_id],
  ]

  def changeset(like \\ %Like{}, attrs, opts \\ []) do
    Changesets.auto(like, attrs, opts, @defaults)
    |> Changeset.assoc_constraint(:liker)
    |> Changeset.assoc_constraint(:liked)
    |> Changeset.unique_constraint([:liker_id, :liked_id])
  end

end
defmodule Bonfire.Data.Social.Like.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Like

  @like_table Like.__schema__(:source)
  @unique_index [:liker_id, :liked_id]

  # create_like_table/{0,1}

  defp make_like_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.Social.Like) do
        Ecto.Migration.add :liker_id, strong_pointer(), null: false
        Ecto.Migration.add :liked_id, strong_pointer(), null: false
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_like_table(), do: make_like_table([])
  defmacro create_like_table([do: {_, _, body}]), do: make_like_table(body)

  # drop_like_table/0

  def drop_like_table(), do: drop_pointable_table(Like)

  # create_like_unique_index/{0,1}

  defp make_like_unique_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.unique_index(unquote(@like_table), unquote(@unique_index), unquote(opts))
      )
    end
  end

  defmacro create_like_unique_index(opts \\ [])
  defmacro create_like_unique_index(opts), do: make_like_unique_index(opts)

  def drop_like_unique_index(opts \\ [])
  def drop_like_unique_index(opts), do: drop_if_exists(unique_index(@like_table, @unique_index, opts))

  defp make_like_liked_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@like_table), [:liked_id], unquote(opts))
      )
    end
  end

  defmacro create_like_liked_index(opts \\ [])
  defmacro create_like_liked_index(opts), do: make_like_liked_index(opts)

  def drop_like_liked_index(opts \\ []) do
    drop_if_exists(index(@like_table, [:liked_id], opts))
  end

  # migrate_like/{0,1}

  defp ml(:up) do
    quote do
      unquote(make_like_table([]))
      unquote(make_like_unique_index([]))
      unquote(make_like_liked_index([]))
    end
  end
  defp ml(:down) do
    quote do
      Bonfire.Data.Social.Like.Migration.drop_like_liked_index()
      Bonfire.Data.Social.Like.Migration.drop_like_unique_index()
      Bonfire.Data.Social.Like.Migration.drop_like_table()
    end
  end

  defmacro migrate_like() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(ml(:up)),
        else: unquote(ml(:down))
    end
  end

  defmacro migrate_like(dir), do: ml(dir)

end
