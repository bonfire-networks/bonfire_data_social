defmodule Bonfire.Data.Social.Inbox do
  use Needle.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_inbox"

  alias Bonfire.Data.Social.Feed
  alias Bonfire.Data.Social.Inbox

  alias Ecto.Changeset

  mixin_schema do
    belongs_to(:feed, Feed)
  end

  @cast [:feed_id, :id]

  def changeset(inbox \\ %Inbox{}, attrs) do
    inbox
    |> Changeset.cast(attrs, @cast)
    |> Changeset.cast_assoc(:feed)
    |> Changeset.assoc_constraint(:feed)
  end
end

defmodule Bonfire.Data.Social.Inbox.Migration do
  @moduledoc false
  use Ecto.Migration
  import Needle.Migration
  alias Bonfire.Data.Social.Inbox

  # create_inbox_table/{0, 1}

  defp make_inbox_table(exprs) do
    quote do
      require Needle.Migration

      Needle.Migration.create_mixin_table Bonfire.Data.Social.Inbox do
        Ecto.Migration.add(:feed_id, Needle.Migration.strong_pointer())
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_inbox_table(), do: make_inbox_table([])
  defmacro create_inbox_table(do: {_, _, body}), do: make_inbox_table(body)

  # drop_inbox_table/0

  def drop_inbox_table(), do: drop_mixin_table(Inbox)

  # migrate_inbox/{0, 1}

  defp mi(:up), do: make_inbox_table([])

  defp mi(:down) do
    quote do
      Bonfire.Data.Social.Inbox.Migration.drop_inbox_table()
    end
  end

  defmacro migrate_inbox() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mi(:up)),
        else: unquote(mi(:down))
    end
  end

  defmacro migrate_inbox(dir), do: mi(dir)
end
