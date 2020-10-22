defmodule CommonsPub.Circles.Encircle do
  @moduledoc """
  """

  use Pointers.Mixin,
    otp_app: :cpub_circles,
    table_id: "1NSERTSAP01NTER1NT0AC1RC1E",
    source: "cpub_circles_encircle"

  alias CommonsPub.Circles.{Circle, Encircle}
  alias Pointers.{Changesets, Pointer}

  mixin_schema do
    belongs_to :subject, Pointer
    belongs_to :circle, Circle
  end

  def changeset(encircle \\ %Encircle{}, attrs, opts \\ []),
    do: Changesets.auto(encircle, attrs, opts, [])
 
end
defmodule CommonsPub.Circles.Encircle.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias CommonsPub.Circles.{Circle, Encircle}

  defmacro create_encircle_table() do
    quote do
      CommonsPub.Circles.Encircle.Migration.create_encircle_table do
      end
    end
  end

  defmacro create_encircle_table([do: body]) do
    quote do
      Pointers.Migrations.create_mixin_table(CommonsPub.Circles.Encircle) do
        Ecto.Migration.add :circle_id,
          Pointers.Migrations.strong_pointer(CommonsPub.Circles.Circle),
          null: false
        Ecto.Migration.add :subject_id,
          Pointers.Migrations.strong_pointer(),
          null: false
        unquote_splicing(body)
      end
    end
  end

  def create_encircle_subject_index(opts \\ []) do
    create_if_not_exists index(Encircle, [:subject_id], opts)
  end

  def create_encircle_unique_index(opts \\ []) do
    create_if_not_exists unique_index(Encircle, [:circle_id, :subject_id], opts)
  end

  def migrate_encircle(dir \\ direction())
  def migrate_encircle(:up) do
    create_encircle_table()
    create_encircle_unique_index()
    create_encircle_subject_index()
  end

  def migrate_encircle(:down) do
    drop_if_exists index(Encircle, [:subject_id])
    drop_if_exists unique_index(Encircle, [:circle_id, :subject_id])
    drop_pointable_table(Encircle)
  end

end
