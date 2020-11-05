defmodule CommonsPub.Circles.Encircle do
  @moduledoc """
  """

  use Pointers.Pointable,
    otp_app: :cpub_circles,
    table_id: "1NSERTSAP01NTER1NT0AC1RC1E",
    source: "cpub_circles_encircle"

  alias CommonsPub.Circles.{Circle, Encircle}
  alias Pointers.{Changesets, Pointer}

  pointable_schema do
    belongs_to :subject, Pointer
    belongs_to :circle, Circle
  end

  def changeset(encircle \\ %Encircle{}, attrs, opts \\ []),
    do: Changesets.auto(encircle, attrs, opts, [])
 
end
defmodule CommonsPub.Circles.Encircle.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias CommonsPub.Circles.Encircle

  @encircle_table Encircle.__schema__(:source)
  @unique_index [:subject_id, :circle_id]
  @secondary_index [:circle_id]

  # create_encircle_table/{0,1}

  defp make_encircle_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(CommonsPub.Circles.Encircle) do
        Ecto.Migration.add :subject_id,
          Pointers.Migration.strong_pointer()
        Ecto.Migration.add :circle_id,
          Pointers.Migration.strong_pointer(CommonsPub.Circles.Circle)
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

  defp make_encircle_secondary_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@encircle_table), unquote(@secondary_index), unquote(opts))
      )
    end
  end

  defmacro create_encircle_secondary_index(opts \\ [])
  defmacro create_encircle_secondary_index(opts), do: make_encircle_secondary_index(opts)

  def drop_encircle_secondary_index(opts \\ [])
  def drop_encircle_secondary_index(opts), do: drop_if_exists(index(@encircle_table, @secondary_index, opts))

  # migrate_encircle/{0,1}

  defp me(:up) do
    quote do
      require CommonsPub.Circles.Encircle.Migration
      CommonsPub.Circles.Encircle.Migration.create_encircle_table()
      CommonsPub.Circles.Encircle.Migration.create_encircle_unique_index()
      CommonsPub.Circles.Encircle.Migration.create_encircle_secondary_index()
    end
  end

  defp me(:down) do
    quote do
      CommonsPub.Circles.Circle.Migration.drop_encircle_secondary_index()
      CommonsPub.Circles.Circle.Migration.drop_encircle_unique_index()
      CommonsPub.Circles.Circle.Migration.drop_encircle_table()
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
