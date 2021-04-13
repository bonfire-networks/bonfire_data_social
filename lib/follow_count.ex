defmodule Bonfire.Data.Social.FollowCount do

  use Pointers.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_follow_count"

  alias Bonfire.Data.Social.FollowCount
  alias Ecto.Changeset

  mixin_schema do
    field :follow_count, :integer, default: 0
    field :follower_count, :integer, default: 0
  end

  @cast [:follow_count, :follower_count]

  def changeset(fc \\ %FollowCount{}, params) do
    Changeset.cast(fc, params, @cast)
  end

end
defmodule Bonfire.Data.Social.FollowCount.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.FollowCount

  @table FollowCount.__schema__(:source)
  @trigger_table Bonfire.Data.Social.Follow.__schema__(:source)

  @create_fun """
  create or replace function #{@table}_update ()
  returns trigger
  language plpgsql
  as $$
  declare
  begin

      IF (TG_OP = 'INSERT') THEN

          -- Increment the number of things the current follower follows
          insert into #{@table}(id, follow_count)
              select NEW."follower_id", 1
          on conflict (id)
              do update
                  set follow_count = #{@table}.follow_count + 1
                  where #{@table}.id = NEW."follower_id";

          -- Increment the number of followers of the thing being followed
          insert into #{@table}(id, follower_count)
              select NEW."followed_id", 1
          on conflict (id)
              do update
                  set follower_count = #{@table}.follower_count + 1
                  where #{@table}.id = NEW."followed_id";

          RETURN NULL;

      ELSIF (TG_OP = 'DELETE') THEN

          -- Decrement the number of things the current unfollower follows
          update #{@table}
              set follow_count = #{@table}.follow_count - 1
              where #{@table}.id = OLD."follower_id";

          -- Decrement the number of followers of the thing being unfollowed
          update #{@table}
              set follower_count = #{@table}.follower_count - 1
              where #{@table}.id = OLD."followed_id";

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
    # IO.inspect(@create_fun)
    # IO.inspect(@create_trigger)
    # this has the appearance of being muddled, but it's not
    Ecto.Migration.execute(@create_fun, @drop_fun)
    Ecto.Migration.execute(@drop_trigger, @drop_trigger) # to replace if changed
    Ecto.Migration.execute(@create_trigger, @drop_trigger)
  end

  # create_follow_count_table/{0,1}

  defp make_follow_count_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_mixin_table(Bonfire.Data.Social.FollowCount) do
        Ecto.Migration.add :follow_count, :bigint, null: false, default: 0
        Ecto.Migration.add :follower_count, :bigint, null: false, default: 0
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_follow_count_table(), do: make_follow_count_table([])
  defmacro create_follow_count_table([do: {_, _, body}]), do: make_follow_count_table(body)

  # drop_follow_count_table/0

  def drop_follow_count_table(), do: drop_mixin_table(FollowCount)

  # create_follow_count_index/{0, 1}

  defp make_follow_count_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@table), [:follow_count], unquote(opts))
      )
    end
  end

  defmacro create_follow_count_index(opts \\ [])
  defmacro create_follow_count_index(opts), do: make_follow_count_index(opts)

  def drop_follow_count_index(opts \\ []) do
    drop_if_exists(index(@table, [:follow_count], opts))
  end

  # create_follower_count_index/{0, 1}

  defp make_follower_count_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@table), [:follower_count], unquote(opts))
      )
    end
  end

  defmacro create_follower_count_index(opts \\ [])
  defmacro create_follower_count_index(opts), do: make_follower_count_index(opts)

  def drop_follower_count_index(opts \\ []) do
    drop_if_exists(index(@table, [:follower_count], opts))
  end


  # migrate_follow_count/{0,1}

  defp mfc(:up) do
    quote do
      unquote(make_follow_count_table([]))
      unquote(make_follow_count_index([]))
      unquote(make_follow_count_index([]))

      Ecto.Migration.flush()

      Bonfire.Data.Social.FollowCount.Migration.migrate_functions()
    end
  end
  defp mfc(:down) do
    quote do

      Bonfire.Data.Social.FollowCount.Migration.migrate_functions()

      Bonfire.Data.Social.FollowCount.Migration.drop_follow_count_index()
      Bonfire.Data.Social.FollowCount.Migration.drop_follow_count_table()
    end
  end

  defmacro migrate_follow_count() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mfc(:up)),
        else: unquote(mfc(:down))
    end
  end
  defmacro migrate_follow_count(dir), do: mfc(dir)

end
