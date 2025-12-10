defmodule Bonfire.Data.Social.PostContent do
  use Needle.Mixin,
    otp_app: :bonfire_data_social,
    source: "bonfire_data_social_post_content"

  # use Cldr.Trans, 
  use Bonfire.Common.Localise.Cldr.Trans,
    # what fields are translatable 
    translates: [:name, :summary, :html_body]

  # makes sure the app's default locale is included as an embeddable translation, because we want to be able to store translations into English too
  @trans_default_locale :und

  alias Bonfire.Data.Social.PostContent
  alias Ecto.Changeset

  mixin_schema do
    field(:name, :string)
    field(:summary, :string)
    field(:html_body, :string)

    translations(:translations, nil, build_field_schema: true)

    # will hold the preferred translated content when queried
    field(:translation, :map, virtual: true)
  end

  @cast [:name, :summary, :html_body]
  @required []

  def changeset(content \\ %PostContent{}, params) do
    content
    |> Changeset.cast(params, @cast)
    |> Changeset.cast_embed(:translations, with: &translations_changeset/2)
    |> Changeset.validate_required(@required)
  end

  defp translations_changeset(translations, params) do
    Bonfire.Common.Localise.known_locales()
    |> Enum.reduce(Changeset.cast(translations, params, []), fn locale, changeset ->
      Changeset.cast_embed(changeset, locale, with: &translations_fields_changeset/2)
    end)
  end

  def translations_fields_changeset(fields, params) do
    fields
    |> Changeset.cast(params, @cast)
  end
end

defmodule Bonfire.Data.Social.PostContent.Migration do
  @moduledoc false
  use Ecto.Migration
  import Needle.Migration
  alias Bonfire.Data.Social.PostContent

  # create_post_content_table/{0,1}

  defp make_post_content_table(exprs) do
    quote do
      require Needle.Migration

      Needle.Migration.create_mixin_table Bonfire.Data.Social.PostContent do
        Ecto.Migration.add(:name, :text)
        Ecto.Migration.add(:summary, :text)
        Ecto.Migration.add(:html_body, :text)
        Ecto.Migration.add(:translations, :map)

        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_post_content_table(), do: make_post_content_table([])

  defmacro create_post_content_table(do: {_, _, body}),
    do: make_post_content_table(body)

  # drop_post_content_table/0

  def drop_post_content_table(), do: drop_mixin_table(PostContent)

  # migrate_post_content/{0,1}

  defp mpc(:up), do: make_post_content_table([])

  defp mpc(:down) do
    quote do
      Bonfire.Data.Social.PostContent.Migration.drop_post_content_table()
    end
  end

  defmacro migrate_post_content() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mpc(:up)),
        else: unquote(mpc(:down))
    end
  end

  defmacro migrate_post_content(dir), do: mpc(dir)

  def add_translations do
    alter table(:bonfire_data_social_post_content) do
      Ecto.Migration.add_if_not_exists(:translations, :map)
    end
  end
end
