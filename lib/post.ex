defmodule Bonfire.Data.Social.Post do
  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "30NF1REP0STTAB1ENVMBER0NEE",
    source: "bonfire_data_social_post"

  alias Bonfire.Data.Social.Post
  alias Pointers.Changesets

  virtual_schema do
  end

  def changeset(post \\ %Post{}, params), do: Changesets.cast(post, params, [])
end

defmodule Bonfire.Data.Social.Post.Migration do
  @moduledoc false
  import Pointers.Migration
  alias Bonfire.Data.Social.Post

  def migrate_post(), do: migrate_virtual(Post)
end
