defmodule Bonfire.Data.Social.Bookmark do

  use Pointers.Virtual,
    otp_app: :bonfire_data_social,
    table_id: "0EMEMBERS0METH1NGSF0R1ATER",
    source: "bonfire_data_social_bookmark"

  alias Bonfire.Data.Social.Bookmark
  alias Ecto.Changeset
  alias Pointers.Pointer

  virtual_schema do
  end

  def changeset(bookmark \\ %Bookmark{}, params) do
    bookmark
    |> Changeset.cast(params, [])
  end

end
defmodule Bonfire.Data.Social.Bookmark.Migration do

  import Pointers.Migration
  alias Bonfire.Data.Social.Bookmark

  def migrate_bookmark(), do: migrate_virtual(Bookmark)

end
