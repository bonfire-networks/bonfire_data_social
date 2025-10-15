defmodule Bonfire.Data.Social.Profile do
  use Needle.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_profile"

  alias Ecto.Changeset
  alias Bonfire.Data.Social.Profile

  mixin_schema do
    field(:name, :string)
    field(:summary, :string)
    field(:website, :string)
    field(:location, :string)
    # NOTE: define the below using Flexto instead
    # belongs_to(:icon, Bonfire.Files.Media)
    # belongs_to(:image, Bonfire.Files.Media)
  end

  @cast [:name, :summary, :website, :location, :icon_id, :image_id]
  @required [:name]

  def changeset(profile \\ %Profile{}, params) do
    profile
    |> Changeset.cast(params, @cast)
    |> Changeset.validate_required(@required)
  end
end

defmodule Bonfire.Data.Social.Profile.Migration do
  @moduledoc false
  use Needle.Migration.Indexable
  alias Bonfire.Data.Social.Profile

  @table Profile.__schema__(:source)

  # create_profile_table/{0,1}

  defp make_profile_table(exprs) do
    quote do
      import Needle.Migration

      Needle.Migration.create_mixin_table Bonfire.Data.Social.Profile do
        Ecto.Migration.add(:name, :text)
        Ecto.Migration.add(:summary, :text)
        Ecto.Migration.add(:website, :text)
        Ecto.Migration.add(:location, :text)
        add_pointer(:icon_id, :strong, Bonfire.Files.Media)
        add_pointer(:image_id, :strong, Bonfire.Files.Media)
        unquote_splicing(exprs)
      end

      add_profile_indexes()
    end
  end

  def add_profile_indexes do
    create_index_for_pointer(@table, :icon_id)
    create_index_for_pointer(@table, :image_id)
  end

  defmacro create_profile_table(), do: make_profile_table([])
  defmacro create_profile_table(do: {_, _, body}), do: make_profile_table(body)

  # drop_profile_table/0

  def drop_profile_table(), do: drop_mixin_table(Profile)

  # migrate_profile/{0,1}

  defp mp(:up), do: make_profile_table([])

  defp mp(:down) do
    quote do
      Bonfire.Data.Social.Profile.Migration.drop_profile_table()
    end
  end

  defmacro migrate_profile() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mp(:up)),
        else: unquote(mp(:down))
    end
  end

  defmacro migrate_profile(dir), do: mp(dir)
end
