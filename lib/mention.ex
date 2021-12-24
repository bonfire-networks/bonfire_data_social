defmodule Bonfire.Data.Social.Mention do

  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "0EFERENCEST0S0MEP01NTAB1EX",
    source: "bonfire_data_social_mention"

  require Pointers.Changesets
  alias Bonfire.Data.Social.Mention
  alias Ecto.Changeset
  alias Pointers.Pointer

  virtual_schema do
  end

  def changeset(mention \\ %Mention{}, params),
    do: Changeset.cast(mention, params, [])

end
defmodule Bonfire.Data.Social.Mention.Migration do

  import Pointers.Migration
  alias Bonfire.Data.Social.Mention

  def migrate_mention(), do: migrate_virtual(Mention)

end
