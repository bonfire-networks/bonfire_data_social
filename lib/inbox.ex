defmodule Bonfire.Data.Social.Inbox do
  use Pointers.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_inbox"

  alias Bonfire.Data.Social.{Inbox, Feed}
  alias Ecto.Changeset
  # alias Pointers.Pointer

  mixin_schema do
    belongs_to :feed, Feed
  end

  @cast [:feed_id, :id]
  @required [:feed_id]

  def changeset(inbox \\ %Inbox{}, attrs) do
    inbox
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.assoc_constraint(:feed)
  end
end

defmodule Bonfire.Data.Social.Inbox.Migration do
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.{Inbox, Feed}

  # create_inbox_table/{0, 1}

  defp make_inbox_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_mixin_table(Bonfire.Data.Social.Inbox) do
        Ecto.Migration.add :feed_id, Pointers.Migration.strong_pointer(Feed)
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_inbox_table(), do: make_inbox_table([])
  defmacro create_inbox_table([do: {_, _, body}]), do: make_inbox_table(body)

  # drop_inbox_table/0

  def drop_inbox_table(), do: drop_mixin_table(Inbox)

  # migrate_inbox/{0, 1}

  defp mcd(:up), do: make_inbox_table([])

  defp mcd(:down) do
    quote do
      Bonfire.Data.Social.Inbox.Migration.drop_inbox_table()
    end
  end

  defmacro migrate_inbox() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mcd(:up)),
        else: unquote(mcd(:down))
    end
  end

  defmacro migrate_inbox(dir), do: mcd(dir)

end
