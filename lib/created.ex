defmodule Bonfire.Data.Social.Created do
  use Pointers.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_created"

  alias Bonfire.Data.Social.Created
  alias Ecto.Changeset
  alias Pointers.Pointer

  mixin_schema do
    belongs_to(:creator, Pointer)
  end

  @cast [:creator_id]
  @required [:creator_id]

  def changeset(created \\ %Created{}, attrs) do
    created
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.assoc_constraint(:creator)
  end
end

defmodule Bonfire.Data.Social.Created.Migration do
  @moduledoc false
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Created

  # create_created_table/{0, 1}

  defp make_created_table(exprs) do
    quote do
      require Pointers.Migration

      Pointers.Migration.create_mixin_table Bonfire.Data.Social.Created do
        Ecto.Migration.add(:creator_id, Pointers.Migration.strong_pointer())
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_created_table(), do: make_created_table([])
  defmacro create_created_table(do: {_, _, body}), do: make_created_table(body)

  # drop_created_table/0

  def drop_created_table(), do: drop_mixin_table(Created)

  # migrate_created/{0, 1}

  defp mcd(:up), do: make_created_table([])

  defp mcd(:down) do
    quote do
      Bonfire.Data.Social.Created.Migration.drop_created_table()
    end
  end

  defmacro migrate_created() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mcd(:up)),
        else: unquote(mcd(:down))
    end
  end

  defmacro migrate_created(dir), do: mcd(dir)
end
