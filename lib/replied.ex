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
    belongs_to :reply_to, Pointer
    belongs_to :thread, Pointer

    @doc "Number of direct replies"
    field :direct_replies_count, :integer, default: 0

    @doc "Number of nested replies (note that the total number of replies is `direct_replies_count` + `nested_replies_count`)"
    field :nested_replies_count, :integer, default: 0

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

  @table Replied.__schema__(:source)
  @trigger_table @table # counts in this case are stored in same table as data being counted

  @create_fun """
create or replace function #{@table}_update ()
returns trigger
language plpgsql
 as $$
 declare
 begin

     IF (TG_OP = 'INSERT') THEN

         -- Increment the number of direct replies of the thing being replied to
         update #{@table}
            set direct_replies_count = #{@table}.direct_replies_count + 1
            where #{@table}.id = NEW."reply_to_id";

         -- Increment the number of nested replies of the thread being replied to
         update #{@table}
            set nested_replies_count = #{@table}.nested_replies_count + 1
            where #{@table}.id = NEW."thread_id" AND #{@table}.id != NEW."reply_to_id";

         -- Increment the number of nested replies of each of the parents in the reply tree path, except when the path id is the same as NEW.id, or was already updated above
         update #{@table}
            set nested_replies_count = #{@table}.nested_replies_count + 1
            where #{@table}.id = ANY(NEW."path") and #{@table}.id != NEW."id" and #{@table}.id != NEW."reply_to_id" and #{@table}.id != NEW."thread_id";

        RETURN NULL;

     ELSIF (TG_OP = 'DELETE') THEN

         -- Decrement the number of replies of the thing being replied to
         update #{@table}
             set direct_replies_count = #{@table}.direct_replies_count - 1
             where #{@table}.id = OLD."reply_to_id";

         -- Decrement the number of nested replies of the thread being replied to
         update #{@table}
             set nested_replies_count = #{@table}.nested_replies_count - 1
             where #{@table}.id = OLD."thread_id" and #{@table}.id != OLD."reply_to_id";

         -- Decrement the number of nested replies of each of the parents in the reply tree path, except for the path ids that were already updated above
         update #{@table}
            set nested_replies_count = #{@table}.nested_replies_count - 1
            where #{@table}.id = ANY(OLD."path") and #{@table}.id != OLD."reply_to_id" and #{@table}.id != OLD."thread_id";

         RETURN NULL;

     END IF;
 end;
 $$;
  """

  @create_trigger """
  create trigger #{@table}_trigger
  AFTER INSERT OR DELETE
      ON #{@trigger_table}
  FOR EACH ROW
      EXECUTE PROCEDURE #{@table}_update();
  """

  @drop_fun "drop function IF EXISTS #{@table}_update CASCADE"
  @drop_trigger "drop trigger IF EXISTS #{@table}_trigger ON #{@trigger_table}"

  def migrate_functions do
    # this has the appearance of being muddled, but it's not
    Ecto.Migration.execute(@create_fun, @drop_fun)
    Ecto.Migration.execute(@drop_trigger, @drop_trigger) # to replace if changed
    Ecto.Migration.execute(@create_trigger, @drop_trigger)
  end

  # create_replied_table/{0, 1}

  defp make_replied_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_mixin_table(unquote(@table)) do

        Ecto.Migration.add :reply_to_id, Pointers.Migration.strong_pointer()
        Ecto.Migration.add :thread_id, Pointers.Migration.strong_pointer()

        Ecto.Migration.add :path, {:array, :uuid}, default: [], null: false

        Ecto.Migration.add :direct_replies_count, :bigint, null: false, default: 0
        Ecto.Migration.add :nested_replies_count, :bigint, null: false, default: 0

        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_replied_table(), do: make_replied_table([])
  defmacro create_replied_table([do: {_, _, body}]), do: make_replied_table(body)

  # drop_replied_table/0

  def drop_replied_table(), do: drop_mixin_table(Replied)

  # migrate_replied/{0, 1}

  defp mcd(:up) do
    make_replied_table([])
    # Ecto.Migration.flush()
    # migrate_functions()
  end

  defp mcd(:down) do
    quote do
      # Bonfire.Data.Social.Replied.Migration.migrate_functions()
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
