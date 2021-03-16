defmodule Bonfire.Data.Social.FeedPublish do

  use Pointers.Pointable,
    otp_app: :bonfire_data_social,
    table_id: "6VTT1NGS0METH1NGS1NT0AFEED",
    source: "bonfire_data_social_feed_publish"

  require Pointers.Changesets
  alias Bonfire.Data.Social.{Feed, FeedPublish, Activity}
  alias Ecto.Changeset
  alias Pointers.Pointer

  pointable_schema do
    belongs_to :feed, Pointer
    # belongs_to :timeline, Timeline, foreign_key: :object_id, define_field: false

    belongs_to :object, Pointer

    # activity aliases object so we can associate them directly
    belongs_to :activity, Activity, foreign_key: :object_id, define_field: false
  end

  @cast     [:feed_id, :object_id]
  @required @cast

  def changeset(pub \\ %FeedPublish{}, params) do
    pub
    |> Changeset.cast(params, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.assoc_constraint(:feed)
    |> Changeset.assoc_constraint(:object)
  end

end
defmodule Bonfire.Data.Social.FeedPublish.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.FeedPublish

  @feed_publish_table FeedPublish.__schema__(:source)

  # create_feed_publish_table/{0,1}

  defp make_feed_publish_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.Social.FeedPublish) do
        Ecto.Migration.add :feed_id,
          Pointers.Migration.strong_pointer(Bonfire.Data.Social.Feed), null: false
        Ecto.Migration.add :object_id,
          Pointers.Migration.strong_pointer(), null: false
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_feed_publish_table(), do: make_feed_publish_table([])
  defmacro create_feed_publish_table([do: {_, _, body}]), do: make_feed_publish_table(body)

  # drop_feed_publish_table/0

  def drop_feed_publish_table(), do: drop_pointable_table(FeedPublish)

  # create_feed_publish_feed_index/{0,1}

  defp make_feed_publish_feed_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@feed_publish_table), [:feed_id], unquote(opts))
      )
    end
  end

  defmacro create_feed_publish_feed_index(opts \\ []),
    do: make_feed_publish_feed_index(opts)

  def drop_feed_publish_feed_index(opts \\ []),
    do: drop_if_exists(index(@feed_publish_table, [:feed_id], opts))

  # create_feed_publish_object_index/{0,1}

  defp make_feed_publish_object_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@feed_publish_table), [:object_id], unquote(opts))
      )
    end
  end

  defmacro create_feed_publish_object_index(opts \\ []),
    do: make_feed_publish_object_index(opts)

  def drop_feed_publish_object_index(opts \\ []),
    do: drop_if_exists(index(@feed_publish_table, [:object_id], opts))

  # migrate_feed/{0,1}

  defp mf(:up) do
    quote do
      unquote(make_feed_publish_table([]))
      unquote(make_feed_publish_feed_index([]))
      unquote(make_feed_publish_object_index([]))
    end
  end

  defp mf(:down) do
    quote do
      Bonfire.Data.Social.FeedPublish.Migration.drop_feed_publish_object_index()
      Bonfire.Data.Social.FeedPublish.Migration.drop_feed_publish_feed_index()
      Bonfire.Data.Social.FeedPublish.Migration.drop_feed_publish_table()
    end
  end

  defmacro migrate_feed_publish() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mf(:up)),
        else: unquote(mf(:down))
    end
  end

  defmacro migrate_feed_publish(dir), do: mf(dir)

end
