defmodule Bonfire.Data.Social.Mention do

  use Pointers.Pointable,
    otp_app: :bonfire_data_social,
    table_id: "0EFERENCEST0S0MEP01NTAB1EX",
    source: "bonfire_data_social_mention"

  require Pointers.Changesets
  alias Bonfire.Data.Social.Mention
  alias Ecto.Changeset
  alias Pointers.Pointer

  pointable_schema do
    belongs_to :mentioner, Pointer
    belongs_to :mentioned, Pointer
  end

  @cast     [:mentioner_id, :mentioned_id]
  @required @cast

  def changeset(mention \\ %Mention{}, params) do
    mention
    |> Changeset.cast(params, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.assoc_constraint(:mentioner)
    |> Changeset.assoc_constraint(:mentioned)
  end

end
defmodule Bonfire.Data.Social.Mention.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Mention

  @mention_table Mention.__schema__(:source)

  # create_mention_table/{0,1}

  defp make_mention_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.Social.Mention) do
        Ecto.Migration.add :mentioner_id,
          Pointers.Migration.strong_pointer(), null: false
        Ecto.Migration.add :mentioned_id,
          Pointers.Migration.strong_pointer(), null: false
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_mention_table(), do: make_mention_table([])
  defmacro create_mention_table([do: {_, _, body}]), do: make_mention_table(body)

  # drop_mention_table/0

  def drop_mention_table(), do: drop_pointable_table(Mention)

  # create_mention_mentioner_index/{0,1}

  defp make_mention_mentioner_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@mention_table), [:mentioner_id], unquote(opts))
      )
    end
  end

  defmacro create_mention_mentioner_index(opts \\ [])
  defmacro create_mention_mentioner_index(opts), do: make_mention_mentioner_index(opts)

  def drop_mention_mentioner_index(opts \\ [])
  def drop_mention_mentioner_index(opts),
    do: drop_if_exists(index(@mention_table, [:mentioner_id], opts))

  defp make_mention_mentioned_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@mention_table), [:mentioned_id], unquote(opts))
      )
    end
  end

  defmacro create_mention_mentioned_index(opts \\ [])
  defmacro create_mention_mentioned_index(opts), do: make_mention_mentioned_index(opts)

  def drop_mention_mentioned_index(opts \\ []) do
    drop_if_exists(index(@mention_table, [:mentioned_id], opts))
  end

  # migrate_mention/{0,1}

  defp mm(:up) do
    quote do
      unquote(make_mention_table([]))
      unquote(make_mention_mentioner_index([]))
      unquote(make_mention_mentioned_index([]))
    end
  end
  defp mm(:down) do
    quote do
      Bonfire.Data.Social.Mention.Migration.drop_mention_mentioned_index()
      Bonfire.Data.Social.Mention.Migration.drop_mention_mentioner_index()
      Bonfire.Data.Social.Mention.Migration.drop_mention_table()
    end
  end

  defmacro migrate_mention() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mm(:up)),
        else: unquote(mm(:down))
    end
  end

  defmacro migrate_mention(dir), do: mm(dir)

end
