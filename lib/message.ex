defmodule Bonfire.Data.Social.Message do
  use Needle.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "6R1VATEMESAGEC0MMVN1CAT10N",
    source: "bonfire_data_social_message"

  alias Bonfire.Data.Social.Message
  alias Needle.Changesets

  virtual_schema do
    field(:thread_id, Needle.ULID, virtual: true)
  end

  def changeset(message \\ %Message{}, params),
    do: Changesets.cast(message, params, [])
end

defmodule Bonfire.Data.Social.Message.Migration do
  @moduledoc false
  import Needle.Migration
  alias Bonfire.Data.Social.Message

  def migrate_message(), do: migrate_virtual(Message)
end
