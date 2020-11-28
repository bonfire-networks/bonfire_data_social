defmodule Bonfire.Data.Social.Circle do
  @moduledoc """
  """

  use Pointers.Pointable,
    otp_app: :bonfire_data_social,
    table_id: "C1RC1ESAREAV1S1B111TYSC0PE",
    source: "bonfire_data_social_circle"

  alias Bonfire.Data.Social.Circle
  alias Pointers.Changesets

  pointable_schema do
  end

  def changeset(circle \\ %Circle{}, attrs, opts \\ []),
    do: Changesets.auto(circle, attrs, opts, [])

end
defmodule Bonfire.Data.Social.Circle.Migration do

  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Circle

  # create_circle_table/{0,1}

  defp make_circle_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.Social.Circle) do
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_circle_table(), do: make_circle_table([])
  defmacro create_circle_table([do: body]), do: make_circle_table(body)

  # drop_circle_table/0

  def drop_circle_table(), do: drop_pointable_table(Circle)

  # migrate_circle/{0,1}

  defp mc(:up), do: make_circle_table([])
  defp mc(:down) do
    quote do: Bonfire.Data.Social.Circle.Migration.drop_circle_table()
  end

  defmacro migrate_circle() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mc(:up)),
        else: unquote(mc(:down))
    end
  end
  defmacro migrate_circle(dir), do: mc(dir)

end
