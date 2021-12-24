defmodule Bonfire.Data.Social.Boost do

  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "300STANN0VNCERESHARESH0VTS",
    source: "bonfire_data_social_boost"

  require Pointers.Changesets
  alias Bonfire.Data.Social.Boost
  alias Ecto.Changeset
  alias Pointers.Pointer

  virtual_schema do
  end

  def changeset(boost \\ %Boost{}, params), do: Changeset.cast(boost, params, [])

end
defmodule Bonfire.Data.Social.Boost.Migration do

  import Pointers.Migration
  alias Bonfire.Data.Social.Boost

  def migrate_boost(), do: migrate_virtual(Boost)

end
