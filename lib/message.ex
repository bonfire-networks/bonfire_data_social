defmodule Bonfire.Data.Social.Message do
  use Pointers.Pointable,
    otp_app: :bonfire_data_social,
    table_id: "PR1VATEMESAGEC0MMVN1CAT10N",
    source: "bonfire_data_social_message"

  alias Bonfire.Data.Social.Message
  alias Ecto.Changeset

  pointable_schema do
  end

  def changeset(message \\ %Message{}, params) do
    Changeset.cast(message, params, [])
  end

end

defmodule Bonfire.Data.Social.Message.Migration do
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Message

  # create_message_table/{0,1}

  defp make_message_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.Social.Message) do
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_message_table(), do: make_message_table([])
  defmacro create_message_table([do: body]), do: make_message_table(body)

  # drop_message_table/0

  def drop_message_table(), do: drop_pointable_table(Message)

  # migrate_message/{0,1}

  defp mp(:up), do: make_message_table([])
  defp mp(:down) do
    quote do: Bonfire.Data.Social.Message.Migration.drop_message_table()
  end

  defmacro migrate_message() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mp(:up)),
        else: unquote(mp(:down))
    end
  end
  defmacro migrate_message(dir), do: mp(dir)

end
