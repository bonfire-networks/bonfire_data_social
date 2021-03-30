defmodule Bonfire.Data.Social.LikeCount do

  use Pointers.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_like_count"

  alias Bonfire.Data.Social.LikeCount
  alias Ecto.Changeset

  mixin_schema do
    field :like_count, :integer, default: 0
    field :liker_count, :integer, default: 0
  end

  @cast [:like_count, :liker_count]

  def changeset(fc \\ %LikeCount{}, params) do
    Changeset.cast(fc, params, @cast)
  end

end
defmodule Bonfire.Data.Social.LikeCount.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.LikeCount

  @table LikeCount.__schema__(:source)
  @trigger_table Bonfire.Data.Social.Like.__schema__(:source)

  @create_fun """
create or replace function #{@table}_update ()
returns trigger
language plpgsql
 as $$
 declare
 begin

     IF (TG_OP = 'INSERT') THEN

         -- Increment the number of things the current liker likes
         insert into #{@table}(id, like_count)
             select NEW."liker_id", 1
         on conflict (id)
             do update
                 set like_count = #{@table}.like_count + 1
                 where #{@table}.id = NEW."liker_id";

         -- Increment the number of likers of the thing being liked
         insert into #{@table}(id, liker_count)
             select NEW."liked_id", 1
         on conflict (id)
             do update
                 set liker_count = #{@table}.liker_count + 1
                 where #{@table}.id = NEW."liked_id";

         RETURN NULL;

     ELSIF (TG_OP = 'DELETE') THEN

         -- Decrement the number of things the current unliker likes
         update #{@table}
             set like_count = #{@table}.like_count - 1
             where #{@table}.id = OLD."liker_id";

         -- Decrement the number of likers of the thing being unliked
         update #{@table}
             set liker_count = #{@table}.liker_count - 1
             where #{@table}.id = OLD."liked_id";

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

  # create_like_count_table/{0,1}

  defp make_like_count_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_mixin_table(Bonfire.Data.Social.LikeCount) do
        Ecto.Migration.add :like_count, :bigint, null: false, default: 0
        Ecto.Migration.add :liker_count, :bigint, null: false, default: 0
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_like_count_table(), do: make_like_count_table([])
  defmacro create_like_count_table([do: {_, _, body}]), do: make_like_count_table(body)

  # drop_like_count_table/0

  def drop_like_count_table(), do: drop_mixin_table(LikeCount)

  # create_like_count_index/{0, 1}

  defp make_like_count_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@table), [:like_count], unquote(opts))
      )
    end
  end

  defmacro create_like_count_index(opts \\ [])
  defmacro create_like_count_index(opts), do: make_like_count_index(opts)

  def drop_like_count_index(opts \\ []) do
    drop_if_exists(index(@table, [:like_count], opts))
  end

  # create_liker_count_index/{0, 1}

  defp make_liker_count_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@table), [:liker_count], unquote(opts))
      )
    end
  end

  defmacro create_liker_count_index(opts \\ [])
  defmacro create_liker_count_index(opts), do: make_liker_count_index(opts)

  def drop_liker_count_index(opts \\ []) do
    drop_if_exists(index(@table, [:liker_count], opts))
  end


  # migrate_like_count/{0,1}

  defp mlc(:up) do
    quote do
      unquote(make_like_count_table([]))
      unquote(make_like_count_index([]))

      Ecto.Migration.flush()

      Bonfire.Data.Social.LikeCount.Migration.migrate_functions()
    end
  end
  defp mlc(:down) do
    quote do
      Bonfire.Data.Social.LikeCount.Migration.migrate_functions()

      Bonfire.Data.Social.LikeCount.Migration.drop_like_count_index()
      Bonfire.Data.Social.LikeCount.Migration.drop_like_count_table()
    end
  end

  defmacro migrate_like_count() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mlc(:up)),
        else: unquote(mlc(:down))
    end
  end
  defmacro migrate_like_count(dir), do: mlc(dir)

end
