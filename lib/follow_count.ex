defmodule Bonfire.Data.Social.FollowCount do
  @moduledoc """
  Schema for batch-querying follow counts from the follow_total database view.
  Created by `Bonfire.Data.Social.Follow.Migration.migrate_follow_total_view/0`.
  """

  use Ecto.Schema

  @primary_key {:id, Needle.ULID, autogenerate: false}
  schema "bonfire_data_social_follow_total" do
    field(:subject_count, :integer)
    field(:object_count, :integer)
  end
end
