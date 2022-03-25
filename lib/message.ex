defmodule Bonfire.Data.Social.Message do

  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "6R1VATEMESAGEC0MMVN1CAT10N",
    source: "bonfire_data_social_message"

  alias Bonfire.Data.Social.Message
  alias Pointers.Changesets

  virtual_schema do
  end

  def changeset(message \\ %Message{}, params), do: Changesets.cast(message, params, [])

end
defmodule Bonfire.Data.Social.Message.Migration do

  import Pointers.Migration
  alias Bonfire.Data.Social.Message

  def migrate_message(), do: migrate_virtual(Message)

end
