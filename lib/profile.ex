defmodule Bonfire.Data.Social.Profile do

  use Pointers.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_profile"

  alias Pointers.Changesets
  alias Bonfire.Data.Social.Profile
  
  mixin_schema do
    field :name, :string
    field :summary, :string
    # belongs_to :icon, Content
    # belongs_to :image, Content
  end

  @defaults [
    cast: [:name, :summary],
    required: [:name, :summary],
    name: [length: [min: 3, max: 50]],
    summary: [length: [min: 20, max: 500]],
  ]

  def changeset(prof \\ %Profile{}, attrs, opts \\ []),
    do: Changesets.auto(prof, attrs, opts, @defaults)

end
defmodule Bonfire.Data.Social.Profile.Migration do

  import Pointers.Migration
  alias Bonfire.Data.Social.Profile

  # create_profile_table/{0,1}

  defp make_profile_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_mixin_table(Bonfire.Data.Social.Profile) do
        Ecto.Migration.add :name, :text
        Ecto.Migration.add :summary, :text
        # Ecto.Migration.add :icon, strong_pointer(Content)
        # Ecto.Migration.add :image, strong_pointer(Content)
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_profile_table(), do: make_profile_table([])
  defmacro create_profile_table([do: {_, _, body}]), do: make_profile_table(body)

  # drop_profile_table/0

  def drop_profile_table(), do: drop_mixin_table(Profile)

  # migrate_profile/{0,1}

  defp mp(:up), do: make_profile_table([])

  defp mp(:down) do
    quote do
      Bonfire.Data.Social.Profile.Migration.drop_profile_account_index()
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
