defmodule Bonfire.Data.Social.Post do

  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "30NF1REP0STTAB1ENVMBER0NEE",
    source: "bonfire_data_social_post"

  alias Bonfire.Data.Social.Post
  alias Ecto.Changeset

  virtual_schema do
  end

  def changeset(post \\ %Post{}, params) do
    Changeset.cast(post, params, [])
  end

end

defmodule Bonfire.Data.Social.Post.Migration do

  import Pointers.Migration
  alias Bonfire.Data.Social.Post

  def migrate_post(), do: migrate_virtual(Post)

end
