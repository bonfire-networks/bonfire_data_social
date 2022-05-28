defmodule Bonfire.Data.Social.FeedPublish do
  @moduledoc """
  A multimixin for an activity/object appearing in a feed.

  A quite interesting thing about this model is that feed_id
  references Pointer, so it isn't only things of type Feed that it can
  appear in, they are just an obvious choice.
  """

  use Pointers.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_feed_publish"

  require Pointers.Changesets
  alias Pointers.Pointer
  alias Bonfire.Data.Social.FeedPublish
  alias Ecto.Changeset

  mixin_schema do
    belongs_to :feed, Pointer, primary_key: true
  end

  @cast     [:feed_id]
  @required [:feed_id]
  def changeset(pub \\ %FeedPublish{}, params) do
    pub
    |> Changeset.cast(params, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.assoc_constraint(:feed)
    |> Changeset.unique_constraint(@cast)
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
      Pointers.Migration.create_mixin_table(Bonfire.Data.Social.FeedPublish) do
        Ecto.Migration.add :feed_id,
          Pointers.Migration.strong_pointer(), primary_key: true
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_feed_publish_table(), do: make_feed_publish_table([])
  defmacro create_feed_publish_table([do: {_, _, body}]), do: make_feed_publish_table(body)

  def drop_feed_publish_table(), do: drop_mixin_table(FeedPublish)


  def migrate_feed_publish_feed_index(dir \\ direction(), opts \\ [])
  def migrate_feed_publish_feed_index(:up, opts),
    do: create_if_not_exists(index(@feed_publish_table, [:feed_id], opts))
  def migrate_feed_publish_feed_index(:down, opts),
    do: drop_if_exists(index(@feed_publish_table, [:feed_id], opts))

  defp mf(:up) do
    quote do
      Bonfire.Data.Social.FeedPublish.Migration.create_feed_publish_table()
      Bonfire.Data.Social.FeedPublish.Migration.migrate_feed_publish_feed_index()
    end
  end

  defp mf(:down) do
    quote do
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
