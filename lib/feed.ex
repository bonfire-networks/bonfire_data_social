defmodule Bonfire.Data.Social.Feed do
  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "1TFEEDS0NTHES0V1S0FM0RTA1S",
    source: "bonfire_data_social_feed"

  alias Bonfire.Data.Social.Feed
  alias Bonfire.Data.Social.FeedPublish
  alias Pointers.Changesets

  virtual_schema do
    has_many(:feed_publishes, FeedPublish,
      references: :id,
      foreign_key: :feed_id
    )
  end

  def changeset(feed \\ %Feed{}, params), do: Changesets.cast(feed, params, [])
end

defmodule Bonfire.Data.Social.Feed.Migration do
  @moduledoc false
  import Pointers.Migration
  alias Bonfire.Data.Social.Feed

  def migrate_feed(), do: migrate_virtual(Feed)
end
