defmodule Bonfire.Data.Social.Post do
  use Pointers.Pointable,
    otp_app: :bonfire_data_social,
    table_id: "B0NF1REP0STTAB1ENVMBER0NEE",
    source: "bonfire_data_social_post"

  alias Bonfire.Data.Social.Post
  alias Ecto.Changeset
  alias Pointers.Pointer

  pointable_schema do
  end

  def changeset(post \\ %Post{}, params) do
    Changeset.cast(post, params, [])
  end

end

defmodule Bonfire.Data.Social.Post.Migration do
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Post

  # create_post_table/{0,1}

  defp make_post_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.Social.Post) do
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_post_table(), do: make_post_table([])
  defmacro create_post_table([do: body]), do: make_post_table(body)

  # drop_post_table/0

  def drop_post_table(), do: drop_pointable_table(Post)

  # migrate_post/{0,1}

  defp mp(:up), do: make_post_table([])
  defp mp(:down) do
    quote do: Bonfire.Data.Social.Post.Migration.drop_post_table()
  end

  defmacro migrate_post() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mp(:up)),
        else: unquote(mp(:down))
    end
  end
  defmacro migrate_post(dir), do: mp(dir)

end
