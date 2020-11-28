defmodule Bonfire.Data.Social.Post do
  use Pointers.Pointable,
    otp_app: :bonfire_posts,
    table_id: "B0NF1REP0STTAB1ENVMBER0NEE",
    source: "bonfire_data_social_post"

  alias __MODULE__
  alias Pointers.Changesets
  alias Pointers.Pointer

  pointable_schema do
    belongs_to :creator, Pointer
  end

  def changeset(post \\ %Post{}, attrs, opts \\ []),
    do: Changesets.auto(post, attrs, opts, [])
end

defmodule Bonfire.Data.Social.Post.Migration do
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Post

  def migrate_post(dir \\ direction())
  def migrate_post(:up) do
    create_pointable_table(Post) do
      add :creator_id, strong_pointer()
    end
  end

  def migrate_post(:down) do
    drop_pointable_table(Post)
  end
end
