defmodule Bonfire.Data.Social.Replied do
  use Pointers.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_replied"

  # to query trees:
  use EctoMaterializedPath
  # use Arbor.Tree, primary_key: :id , primary_key_type: Pointers.ULID, foreign_key: :reply_to_id, foreign_key_type: Pointers.ULID

  alias Bonfire.Data.Social.Replied
  alias Ecto.Changeset
  alias Pointers.Pointer

  mixin_schema do
    belongs_to :thread, Pointer
    belongs_to :reply_to, Pointer
    # field :depth, :integer, virtual: true
    field :path, EctoMaterializedPath.ULIDs, default: [] # default is important here
  end

  @cast [:reply_to_id, :thread_id]
  @required [:reply_to_id]

  def changeset(replied \\ %Replied{}, %{reply_to: reply_to} = attrs) do
    replied
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
    |> make_child_of(reply_to) # set tree path (powered by EctoMaterializedPath)
    |> Changeset.assoc_constraint(:reply_to)
  end

  # for top-level posts
  def changeset(replied, attrs) do
    replied
    |> Changeset.cast(attrs, @cast)
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
        Ecto.Migration.add :path, {:array, :uuid}, default: [], null: false
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
