defmodule Bonfire.Data.Social.Request do
  use Pointers.Pointable,
    otp_app: :bonfire_data_social,
    table_id: "7NEEDPERM1SS10NT0D0TH1SN0W",
    source: "bonfire_data_social_request"

  require Pointers.Changesets
  alias Bonfire.Data.Social.Request
  alias Bonfire.Data.Edges.Edge
  alias Ecto.Changeset
  use Arrows

  pointable_schema do
    field(:accepted_at, :utc_datetime_usec)
    field(:ignored_at, :utc_datetime_usec)
    has_one(:edge, Edge, foreign_key: :id)
  end

  @cast [:id, :accepted_at, :ignored_at]

  def changeset(request \\ %Request{}, params)
  def changeset(request, params), do: Changeset.cast(request, params, @cast)
end

defmodule Bonfire.Data.Social.Request.Migration do
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Request

  # create_request_table/{0,1}

  defp make_request_table(exprs) do
    quote do
      require Pointers.Migration

      Pointers.Migration.create_pointable_table Bonfire.Data.Social.Request do
        add(:accepted_at, :timestamptz, null: true)
        add(:ignored_at, :timestamptz, null: true)
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_request_table(), do: make_request_table([])
  defmacro create_request_table(do: body), do: make_request_table(body)

  # drop_request_table/0

  def drop_request_table(), do: drop_pointable_table(Request)

  # migrate_request/{0,1}

  defp mr(:up), do: make_request_table([])

  defp mr(:down) do
    quote do: Bonfire.Data.Social.Request.Migration.drop_request_table()
  end

  defmacro migrate_request() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mr(:up)),
        else: unquote(mr(:down))
    end
  end

  defmacro migrate_request(dir), do: mr(dir)
end
