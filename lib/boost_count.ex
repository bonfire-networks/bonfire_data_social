defmodule Bonfire.Data.Social.BoostCount do

  use Pointers.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_boost_count"

  alias Bonfire.Data.Social.BoostCount
  alias Ecto.Changeset

  mixin_schema do
    field :boost_count, :integer, default: 0
    field :booster_count, :integer, default: 0
  end

  @cast [:boost_count, :booster_count]

  def changeset(fc \\ %BoostCount{}, params) do
    Changeset.cast(fc, params, @cast)
  end

end
defmodule Bonfire.Data.Social.BoostCount.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.BoostCount

  @table BoostCount.__schema__(:source)
  @trigger_table Bonfire.Data.Social.Boost.__schema__(:source)

  @create_fun """
create or replace function #{@table}_update ()
returns trigger
language plpgsql
 as $$
 declare
 begin

     IF (TG_OP = 'INSERT') THEN

         -- Increment the number of things the current booster boosts
         insert into #{@table}(id, boost_count)
             select NEW."booster_id", 1
         on conflict (id)
             do update
                 set boost_count = #{@table}.boost_count + 1
                 where #{@table}.id = NEW."booster_id";

         -- Increment the number of boosters of the thing being boosted (= number of boosts)
         insert into #{@table}(id, booster_count)
             select NEW."boosted_id", 1
         on conflict (id)
             do update
                 set booster_count = #{@table}.booster_count + 1
                 where #{@table}.id = NEW."boosted_id";

         RETURN NULL;

     ELSIF (TG_OP = 'DELETE') THEN

         -- Decrement the number of things the current unbooster boosts
         update #{@table}
             set boost_count = #{@table}.boost_count - 1
             where #{@table}.id = OLD."booster_id";

         -- Decrement the number of boosters of the thing being unboosted
         update #{@table}
             set booster_count = #{@table}.booster_count - 1
             where #{@table}.id = OLD."boosted_id";

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

  # create_boost_count_table/{0,1}

  defp make_boost_count_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_mixin_table(Bonfire.Data.Social.BoostCount) do
        Ecto.Migration.add :boost_count, :bigint, null: false, default: 0
        Ecto.Migration.add :booster_count, :bigint, null: false, default: 0
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_boost_count_table(), do: make_boost_count_table([])
  defmacro create_boost_count_table([do: {_, _, body}]), do: make_boost_count_table(body)

  # drop_boost_count_table/0

  def drop_boost_count_table(), do: drop_mixin_table(BoostCount)

  # create_boost_count_index/{0, 1}

  defp make_boost_count_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@table), [:boost_count], unquote(opts))
      )
    end
  end

  defmacro create_boost_count_index(opts \\ [])
  defmacro create_boost_count_index(opts), do: make_boost_count_index(opts)

  def drop_boost_count_index(opts \\ []) do
    drop_if_exists(index(@table, [:boost_count], opts))
  end

  # create_booster_count_index/{0, 1}

  defp make_booster_count_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@table), [:booster_count], unquote(opts))
      )
    end
  end

  defmacro create_booster_count_index(opts \\ [])
  defmacro create_booster_count_index(opts), do: make_booster_count_index(opts)

  def drop_booster_count_index(opts \\ []) do
    drop_if_exists(index(@table, [:booster_count], opts))
  end


  # migrate_boost_count/{0,1}

  defp mlc(:up) do
    quote do
      unquote(make_boost_count_table([]))
      unquote(make_boost_count_index([]))

      Ecto.Migration.flush()

      Bonfire.Data.Social.BoostCount.Migration.migrate_functions()
    end
  end
  defp mlc(:down) do
    quote do
      Bonfire.Data.Social.BoostCount.Migration.migrate_functions()

      Bonfire.Data.Social.BoostCount.Migration.drop_boost_count_index()
      Bonfire.Data.Social.BoostCount.Migration.drop_boost_count_table()
    end
  end

  defmacro migrate_boost_count() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mlc(:up)),
        else: unquote(mlc(:down))
    end
  end
  defmacro migrate_boost_count(dir), do: mlc(dir)

end
