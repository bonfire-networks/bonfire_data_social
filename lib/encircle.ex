defmodule Bonfire.Data.Social.Encircle do
  @moduledoc """
  """

  use Pointers.Pointable,
    otp_app: :bonfire_data_social,
    table_id: "1NSERTSAP01NTER1NT0AC1RC1E",
    source: "bonfire_data_social_encircle"

  alias Bonfire.Data.Social.{Circle, Encircle}
  alias Pointers.{Changesets, Pointer}

  pointable_schema do
    belongs_to :subject, Pointer
    belongs_to :circle, Circle
  end

  def changeset(encircle \\ %Encircle{}, attrs, opts \\ []),
    do: Changesets.auto(encircle, attrs, opts, [])
 
end
defmodule Bonfire.Data.Social.Encircle.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Encircle

  @encircle_table Encircle.__schema__(:source)
  @unique_index [:subject_id, :circle_id]

  # create_encircle_table/{0,1}

  defp make_encircle_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.Social.Encircle) do
        Ecto.Migration.add :subject_id,
          Pointers.Migration.strong_pointer()
        Ecto.Migration.add :circle_id,
          Pointers.Migration.strong_pointer(Bonfire.Data.Social.Circle)
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_encircle_table(), do: make_encircle_table([])
  defmacro create_encircle_table([do: {_, _, body}]), do: make_encircle_table(body)

  # drop_encircle_table/0

  def drop_encircle_table(), do: drop_pointable_table(Encircle)

  # create_encircle_unique_index/{0,1}

  defp make_encircle_unique_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.unique_index(unquote(@encircle_table), unquote(@unique_index), unquote(opts))
      )
    end
  end

  defmacro create_encircle_unique_index(opts \\ [])
  defmacro create_encircle_unique_index(opts), do: make_encircle_unique_index(opts)

  def drop_encircle_unique_index(opts \\ [])
  def drop_encircle_unique_index(opts), do: drop_if_exists(unique_index(@encircle_table, @unique_index, opts))

  defp make_encircle_circle_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@encircle_table), [:circle_id], unquote(opts))
      )
    end
  end

  defmacro create_encircle_circle_index(opts \\ [])
  defmacro create_encircle_circle_index(opts), do: make_encircle_circle_index(opts)

  def drop_encircle_circle_index(opts \\ [])
  def drop_encircle_circle_index(opts), do: drop_if_exists(index(@encircle_table, [:circle_id], opts))

  # migrate_encircle/{0,1}

  defp me(:up) do
    quote do
      unquote(make_encircle_table([]))
      unquote(make_encircle_unique_index([]))
      unquote(make_encircle_circle_index([]))
    end
  end

  defp me(:down) do
    quote do
      Bonfire.Data.Social.Encircle.Migration.drop_encircle_circle_index()
      Bonfire.Data.Social.Encircle.Migration.drop_encircle_unique_index()
      Bonfire.Data.Social.Encircle.Migration.drop_encircle_table()
    end
  end

  defmacro migrate_encircle() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(me(:up)),
        else: unquote(me(:down))
    end
  end
  defmacro migrate_encircle(dir), do: me(dir)

end
