defmodule Bonfire.Data.Social.Emoji do
  use Needle.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "3EM0J1T0EXPRESS0VREM0T10NS",
    source: "bonfire_data_social_emoji"

  # alias Bonfire.Data.Edges.Edge
  alias Bonfire.Data.Social.Emoji
  alias Needle.Changesets

  virtual_schema do
  end

  def changeset(emoji \\ %Emoji{}, params), do: Changesets.cast(emoji, params, [])
end

defmodule Bonfire.Data.Social.Emoji.Migration do
  @moduledoc false
  import Ecto.Migration
  import Needle.Migration
  alias Bonfire.Data.Social.Emoji

  def migrate_emoji_view(), do: migrate_virtual(Emoji)

  def migrate_emoji(dir \\ direction())

  def migrate_emoji(:up) do
    migrate_emoji_view()
  end

  def migrate_emoji(:down) do
    migrate_emoji_view()
  end
end
