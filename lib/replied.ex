defmodule Bonfire.Data.Social.Replied do
  use Pointers.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_replied"

  # to query trees:
  use EctoMaterializedPath

  import Untangle

  alias Bonfire.Data.Social.Replied
  alias Ecto.Changeset
  alias Pointers.Pointer

  mixin_schema do
    belongs_to(:reply_to, Pointer)
    belongs_to(:thread, Pointer)
    # Kept updated by triggers. Total replies = direct replies + nested replies.
    field(:direct_replies_count, :integer, default: 0)
    field(:nested_replies_count, :integer, default: 0)
    # default is important here
    field(:path, EctoMaterializedPath.ULIDs, default: [])
  end

  @cast [:reply_to_id, :thread_id]

  # @required [:reply_to_id]

  def changeset(replied \\ %Replied{}, attrs)

  # for replies
  def changeset(replied, %{reply_to: %{replied: %{id: _} = replied_to}} = attrs) do
    # EctoMaterializedPath needs the Replied struct
    changeset(replied, Map.put(attrs, :reply_to, replied_to))
  end

  def changeset(
        replied,
        %{reply_to: %Replied{id: reply_to_id} = replied_to} = attrs
      ) do
    debug(
      "Replied - recording reply_to #{inspect(reply_to_id)} in thread #{inspect(attrs[:thread_id])}"
    )

    replied
    # |> Changeset.validate_required(@required)
    |> Changeset.cast(Map.put(attrs, :reply_to_id, reply_to_id), @cast)
    |> Changeset.assoc_constraint(:reply_to)
    # set tree path (powered by EctoMaterializedPath)
    |> make_child_of(replied_to)
  end

  def changeset(_replied, %{reply_to_id: reply_to_id} = attrs)
      when not is_nil(reply_to_id) do
    error(
      "Replied: you must pass the struct of the object being replied to, an ID is not enough, got: #{inspect(attrs)}"
    )

    raise "Could not record the reply."
  end

  # for top-level posts only
  def changeset(replied, attrs) do
    debug("Replied - recording a top level post")

    Changeset.cast(replied, attrs, @cast)
  end
end

defmodule Bonfire.Data.Social.Replied.Migration do
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Replied

  @table Replied.__schema__(:source)
  # counts in this case are stored in same table as data being counted
  @trigger_table @table

  def create_fun,
    do: """
    create or replace function "#{@table}_update" ()
    returns trigger
    language plpgsql
    as $$
    declare
    begin
      if (TG_OP = 'INSERT') then
        -- Increment the number of direct replies of the thing being replied to
        update "#{@table}"
          set direct_replies_count = direct_replies_count + 1
          where id = NEW.reply_to_id;
        -- Increment the number of nested replies of the thread being replied to
        update "#{@table}"
          set nested_replies_count = nested_replies_count + 1
          where id  = NEW.thread_id
            and id != NEW.reply_to_id;
        -- Increment the number of nested replies of each of the parents in the reply tree path,
        -- except when the path id is the same as NEW.id, or was already updated above
        update "#{@table}"
          set nested_replies_count = nested_replies_count + 1
          where id  = ANY(NEW.path)
            and id != NEW.id
            and id != NEW.reply_to_id
            and id != NEW.thread_id;
        return NULL;
      elsif (TG_OP = 'DELETE') then
        -- Decrement the number of replies of the thing being replied to
        update "#{@table}"
          set direct_replies_count = direct_replies_count - 1
          where id = OLD.reply_to_id;
        -- Decrement the number of nested replies of the thread being replied to
        update "#{@table}"
          set nested_replies_count = nested_replies_count - 1
          where id  = OLD.thread_id
            and id != OLD.reply_to_id;
        -- Decrement the number of nested replies of each of the parents in the reply tree path, except for the path ids that were already updated above
        update "#{@table}"
          set nested_replies_count = nested_replies_count - 1
          where id  = ANY(OLD.path)
            and id != OLD.reply_to_id
            and id != OLD.thread_id;
        return null;
      end if;
    end;
    $$;
    """

  def create_trigger,
    do: """
    create trigger "#{@table}_trigger"
    after insert or delete on "#{@trigger_table}"
    for each row execute procedure "#{@table}_update"();
    """

  @drop_fun ~s[drop function if exists "#{@table}_update" CASCADE]
  @drop_trigger ~s[drop trigger if exists "#{@table}_trigger" ON "#{@trigger_table}"]

  def migrate_functions do
    # this has the appearance of being muddled, but it's not
    Ecto.Migration.execute(create_fun(), @drop_fun)
    # to replace if changed
    Ecto.Migration.execute(@drop_trigger, @drop_trigger)
    Ecto.Migration.execute(create_trigger(), @drop_trigger)
  end

  # create_replied_table/{0, 1}

  defp make_replied_table(exprs) do
    quote do
      require Pointers.Migration

      Pointers.Migration.create_mixin_table unquote(@table) do
        Ecto.Migration.add(:reply_to_id, Pointers.Migration.strong_pointer())
        Ecto.Migration.add(:thread_id, Pointers.Migration.strong_pointer())
        Ecto.Migration.add(:path, {:array, :uuid}, default: [], null: false)

        Ecto.Migration.add(:direct_replies_count, :bigint,
          null: false,
          default: 0
        )

        Ecto.Migration.add(:nested_replies_count, :bigint,
          null: false,
          default: 0
        )

        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_replied_table(), do: make_replied_table([])
  defmacro create_replied_table(do: {_, _, body}), do: make_replied_table(body)

  # drop_replied_table/0

  def drop_replied_table(), do: drop_mixin_table(Replied)

  # migrate_replied/{0, 1}

  defp mcd(:up) do
    make_replied_table([])

    # Ecto.Migration.flush()
    # migrate_functions() # put this in your app's migration instead
  end

  defp mcd(:down) do
    quote do
      Bonfire.Data.Social.Replied.Migration.migrate_functions()
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
