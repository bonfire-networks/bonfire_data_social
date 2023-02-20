defmodule Bonfire.Data.Social.PostContent do
  use Pointers.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_post_content"

  alias Bonfire.Data.Social.PostContent
  alias Ecto.Changeset

  mixin_schema do
    field(:name, :string)
    field(:summary, :string)
    field(:html_body, :string)
  end

  @cast [:name, :summary, :html_body]
  @required [:html_body]

  def changeset(content \\ %PostContent{}, params) do
    content
    |> Changeset.cast(params, @cast)
    |> Changeset.validate_required(@required)
  end
end

defmodule Bonfire.Data.Social.PostContent.Migration do
  @moduledoc false
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.PostContent

  # create_post_content_table/{0,1}

  defp make_post_content_table(exprs) do
    quote do
      require Pointers.Migration

      Pointers.Migration.create_mixin_table Bonfire.Data.Social.PostContent do
        Ecto.Migration.add(:name, :text)
        Ecto.Migration.add(:summary, :text)
        Ecto.Migration.add(:html_body, :text)
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_post_content_table(), do: make_post_content_table([])

  defmacro create_post_content_table(do: {_, _, body}),
    do: make_post_content_table(body)

  # drop_post_content_table/0

  def drop_post_content_table(), do: drop_mixin_table(PostContent)

  # migrate_post_content/{0,1}

  defp mpc(:up), do: make_post_content_table([])

  defp mpc(:down) do
    quote do
      Bonfire.Data.Social.PostContent.Migration.drop_post_content_table()
    end
  end

  defmacro migrate_post_content() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mpc(:up)),
        else: unquote(mpc(:down))
    end
  end

  defmacro migrate_post_content(dir), do: mpc(dir)
end
