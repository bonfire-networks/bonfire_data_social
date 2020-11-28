defmodule Bonfire.Data.Social.Bookmark do

  use Pointers.Pointable,
    otp_app: :bonfire_data_social,
    table_id: "REMEMBERS0METH1NGSF0R1ATER",
    source: "bonfire_data_social_bookmark"

  require Pointers.Changesets
  alias Bonfire.Data.Social.Bookmark
  alias Pointers.{Changesets, Pointer}
  
  pointable_schema do
    belongs_to :bookmarker, Pointer
    belongs_to :bookmarked, Pointer
  end

  @defaults [
    cast:     [:bookmarker_id, :bookmarked_id],
    required: [:bookmarker_id, :bookmarked_id],
  ]
  def changeset(bookmark \\ %Bookmark{}, attrs, opts \\ []),
    do: Changesets.auto(bookmark, attrs, opts, @defaults)

end
defmodule Bonfire.Data.Social.Bookmark.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Bookmark

  @bookmark_table Bookmark.__schema__(:source)

  # create_bookmark_table/{0,1}

  defp make_bookmark_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.Social.Bookmark) do
        Ecto.Migration.add :bookmarker_id, strong_pointer(), null: false
        Ecto.Migration.add :bookmarked_id, strong_pointer(), null: false
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_bookmark_table(), do: make_bookmark_table([])
  defmacro create_bookmark_table([do: {_, _, body}]), do: make_bookmark_table(body)

  # drop_bookmark_table/0

  def drop_bookmark_table(), do: drop_pointable_table(Bookmark)

  # create_bookmark_bookmarker_index/{0,1}

  defp make_bookmark_bookmarker_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@bookmark_table), [:bookmarker_id], unquote(opts))
      )
    end
  end

  defmacro create_bookmark_bookmarker_index(opts \\ [])
  defmacro create_bookmark_bookmarker_index(opts), do: make_bookmark_bookmarker_index(opts)

  def drop_bookmark_bookmarker_index(opts \\ [])
  def drop_bookmark_bookmarker_index(opts),
    do: drop_if_exists(index(@bookmark_table, [:bookmarker_id], opts))

  defp make_bookmark_bookmarked_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@bookmark_table), [:bookmarked_id], unquote(opts))
      )
    end
  end

  defmacro create_bookmark_bookmarked_index(opts \\ [])
  defmacro create_bookmark_bookmarked_index(opts), do: make_bookmark_bookmarked_index(opts)

  def drop_bookmark_bookmarked_index(opts \\ []) do
      drop_if_exists(index(@bookmark_table, [:bookmarked_id], opts))
  end

  # migrate_bookmark/{0,1}

  defp mb(:up) do
    quote do
      unquote(make_bookmark_table([]))
      unquote(make_bookmark_bookmarker_index([]))
      unquote(make_bookmark_bookmarked_index([]))
    end
  end
  defp mb(:down) do
    quote do
      Bonfire.Data.Social.Bookmark.Migration.drop_bookmark_bookmarked_index()
      Bonfire.Data.Social.Bookmark.Migration.drop_bookmark_bookmarker_index()
      Bonfire.Data.Social.Bookmark.Migration.drop_bookmark_table()
    end
  end

  defmacro migrate_bookmark() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mb(:up)),
        else: unquote(mb(:down))
    end
  end

  defmacro migrate_bookmark(dir), do: mb(dir)

end
