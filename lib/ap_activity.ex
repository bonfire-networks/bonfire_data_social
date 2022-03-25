defmodule Bonfire.Data.Social.APActivity do

  use Pointers.Pointable,
    otp_app: :bonfire_data_social,
    table_id: "30NF1REAPACTTAB1ENVMBER0NE",
    source: "bonfire_data_social_apactivity"

  alias Bonfire.Data.Social.APActivity
  alias Ecto.Changeset
  alias Pointers.Changesets

  pointable_schema do
    field :json, :map
  end

  @cast [:json]
  @required [:json]

  def changeset(activity \\ %APActivity{}, params) do
    activity
    |> Changesets.cast(params, @cast)
    |> Changeset.validate_required(@required)
  end
end
defmodule Bonfire.Data.Social.APActivity.Migration do
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.APActivity

  defp make_apactivity_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.Social.APActivity) do
        Ecto.Migration.add :json, :jsonb
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_apactivity_table, do: make_apactivity_table([])
  defmacro create_apactivity_table([do: body]), do: make_apactivity_table(body)

  def drop_apactivity_table(), do: drop_pointable_table(APActivity)

  defp maa(:up), do: make_apactivity_table([])
  defp maa(:down) do
    quote do: Bonfire.Data.Social.APActivity.Migration.drop_apactivity_table()
  end

  defmacro migrate_apactivity() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(maa(:up)),
        else: unquote(maa(:down))
    end
  end
  defmacro migrate_apactivity(dir), do: maa(dir)
end
