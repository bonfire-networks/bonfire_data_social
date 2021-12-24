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
    belongs_to :feed_pointer, Pointer, foreign_key: :feed_id, define_field: false

    belongs_to :activity, Activity
  end

  @cast     [:feed_id, :activity_id]
  @required @cast

  def changeset(pub \\ %FeedPublish{}, params) do
    pub
    |> Changeset.cast(params, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.assoc_constraint(:feed)
    |> Changeset.assoc_constraint(:activity)
    |> Changeset.unique_constraint([:feed_id, :activity_id])
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
          Pointers.Migration.strong_pointer(), null: false
        Ecto.Migration.add :activity_id,
          Pointers.Migration.strong_pointer(), null: false
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_feed_publish_table(), do: make_feed_publish_table([])
  defmacro create_feed_publish_table([do: {_, _, body}]), do: make_feed_publish_table(body)

  def drop_feed_publish_table(), do: drop_pointable_table(FeedPublish)


  def migrate_feed_publish_feed_index(dir \\ direction(), opts \\ [])
  def migrate_feed_publish_feed_index(:up, opts),
    do: create_if_not_exists(index(@feed_publish_table, [:feed_id], opts))
  def migrate_feed_publish_feed_index(:down, opts),
    do: drop_if_exists(index(@feed_publish_table, [:feed_id], opts))

  def migrate_feed_publish_activity_index(dir \\ direction(), opts \\ [])
  def migrate_feed_publish_activity_index(:up, opts),
    do: create_if_not_exists(index(@feed_publish_table, [:activity_id], opts))
  def migrate_feed_publish_activity_index(:down, opts),
    do: drop_if_exists(index(@feed_publish_table, [:activity_id], opts))


  defp mf(:up) do
    quote do
      Bonfire.Data.Social.FeedPublish.Migration.create_feed_publish_table()
      Bonfire.Data.Social.FeedPublish.Migration.migrate_feed_publish_feed_index()
      Bonfire.Data.Social.FeedPublish.Migration.migrate_feed_publish_activity_index()
    end
  end

  defp mf(:down) do
    quote do
      Bonfire.Data.Social.FeedPublish.Migration.migrate_feed_publish_activity_index()
      Bonfire.Data.Social.FeedPublish.Migration.migrate_feed_publish_feed_index()
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
