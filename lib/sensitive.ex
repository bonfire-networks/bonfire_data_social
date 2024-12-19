defmodule Bonfire.Data.Social.Sensitive do
  use Needle.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_sensitive"

  alias Bonfire.Data.Social.Sensitive
  alias Ecto.Changeset
  # alias Needle.Pointer

  mixin_schema do
    field(:is_sensitive, :boolean)
  end

  @cast [:is_sensitive]
  @required []

  def changeset(sensitive \\ %Sensitive{}, attrs) do
    sensitive
    |> Changeset.cast(attrs, @cast)
    |> Changeset.validate_required(@required)
  end
end

defmodule Bonfire.Data.Social.Sensitive.Migration do
  @moduledoc false
  use Ecto.Migration
  import Needle.Migration
  alias Bonfire.Data.Social.Sensitive

  # create_sensitive_table/{0, 1}

  defp make_sensitive_table(exprs) do
    quote do
      require Needle.Migration

      Needle.Migration.create_mixin_table Bonfire.Data.Social.Sensitive do
        Ecto.Migration.add(:is_sensitive, :bool,
          null: false,
          default: false
        )

        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_sensitive_table(), do: make_sensitive_table([])
  defmacro create_sensitive_table(do: {_, _, body}), do: make_sensitive_table(body)

  # drop_sensitive_table/0

  def drop_sensitive_table(), do: drop_mixin_table(Sensitive)

  # migrate_sensitive/{0, 1}

  defp mcd(:up), do: make_sensitive_table([])

  defp mcd(:down) do
    quote do
      Bonfire.Data.Social.Sensitive.Migration.drop_sensitive_table()
    end
  end

  defmacro migrate_sensitive() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mcd(:up)),
        else: unquote(mcd(:down))
    end
  end

  defmacro migrate_sensitive(dir), do: mcd(dir)
end
