defmodule Bonfire.Data.Social.Replied do
  use Pointers.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_replied"

  alias Bonfire.Data.Social.Replied
  alias Ecto.Changeset
  alias Pointers.Pointer

  mixin_schema do
    belongs_to :thread, Pointer
    belongs_to :reply_to, Pointer
  end

  @cast [:reply_to_id, :thread_id]
  @required [:reply_to_id]

  def changeset(replied \\ %Replied{}, attrs) do
    replied
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.assoc_constraint(:reply_to)
  end
end

defmodule Bonfire.Data.Social.Replied.Migration do
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Replied

  # create_replied_table/{0, 1}

  defp make_replied_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_mixin_table("bonfire_data_social_replied") do
        Ecto.Migration.add :thread_id, Pointers.Migration.strong_pointer()
        Ecto.Migration.add :reply_to_id, Pointers.Migration.strong_pointer()
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_replied_table(), do: make_replied_table([])
  defmacro create_replied_table([do: {_, _, body}]), do: make_replied_table(body)

  # drop_replied_table/0

  def drop_replied_table(), do: drop_mixin_table(Replied)

  # migrate_replied/{0, 1}

  defp mcd(:up), do: make_replied_table([])

  defp mcd(:down) do
    quote do
      Bonfire.Data.Social.Replied.Migration.drop_replied_table()
    end
  end

  defmacro migrate_replied() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mcd(:up)),
        else: unquote(mcd(:down))
    end
  end

  defmacro migrate_replied(dir), do: mcd(dir)

end
