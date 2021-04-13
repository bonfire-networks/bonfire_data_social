defmodule Bonfire.Data.Social.Feed do

  use Pointers.Pointable,
    otp_app: :bonfire_data_social,
    table_id: "1TFEEDS0NTHES0V1S0FM0RTA1S",
    source: "bonfire_data_social_feed"

  require Pointers.Changesets
  alias Bonfire.Data.Social.Feed
  alias Bonfire.Data.Social.FeedPublish
  alias Ecto.Changeset
  # alias Pointers.Pointer

  pointable_schema do
    has_many :feed_publishes, FeedPublish, references: :id
  end

  def changeset(feed \\ %Feed{}, params) do
    Changeset.cast(feed, params, [:id])
  end

end
defmodule Bonfire.Data.Social.Feed.Migration do

  # import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Feed

  # @feed_table Feed.__schema__(:source)

  # create_feed_table/{0,1}

  defp make_feed_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.Social.Feed) do
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_feed_table(), do: make_feed_table([])
  defmacro create_feed_table([do: {_, _, body}]), do: make_feed_table(body)

  # drop_feed_table/0

  def drop_feed_table(), do: drop_pointable_table(Feed)

  # migrate_feed/{0,1}

  defp mf(:up), do: make_feed_table([])
  defp mf(:down) do
    quote do
      Bonfire.Data.Social.Feed.Migration.drop_feed_table()
    end
  end

  defmacro migrate_feed() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mf(:up)),
        else: unquote(mf(:down))
    end
  end

  defmacro migrate_feed(dir), do: mf(dir)

end
