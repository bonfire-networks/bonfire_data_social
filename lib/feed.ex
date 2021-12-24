defmodule Bonfire.Data.Social.Feed do

  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "1TFEEDS0NTHES0V1S0FM0RTA1S",
    source: "bonfire_data_social_feed"

  require Pointers.Changesets
  alias Bonfire.Data.Social.Feed
  alias Bonfire.Data.Social.FeedPublish
  alias Ecto.Changeset
  # alias Pointers.Pointer

  virtual_schema do
    has_many :feed_publishes, FeedPublish, references: :id
  end

  def changeset(feed \\ %Feed{}, params) do
    Changeset.cast(feed, params, [:id])
  end

end
defmodule Bonfire.Data.Social.Feed.Migration do

  import Pointers.Migration
  alias Bonfire.Data.Social.Feed

  def migrate_feed(), do: migrate_virtual(Feed)

end
