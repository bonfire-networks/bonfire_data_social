defmodule Bonfire.Data.Social.Article do
  use Pointers.Pointable,
    otp_app: :bonfire_data_social,
    table_id: "B10GP0ST0RS0METH1NGS1M11AR",
    source: "bonfire_data_social_article"

  # Note: we're using Post instead

  alias Bonfire.Data.Social.Article
  alias Ecto.Changeset
  alias Pointers.Pointer

  pointable_schema do
  end

  def changeset(article \\ %Article{}, params) do
    Changeset.cast(article, params, [])
  end

end

defmodule Bonfire.Data.Social.Article.Migration do
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Article

  # create_article_table/{0,1}

  defp make_article_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.Social.Article) do
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_article_table(), do: make_article_table([])
  defmacro create_article_table([do: body]), do: make_article_table(body)

  # drop_article_table/0

  def drop_article_table(), do: drop_pointable_table(Article)

  # migrate_article/{0,1}

  defp ma(:up), do: make_article_table([])
  defp ma(:down) do
    quote do: Bonfire.Data.Social.Article.Migration.drop_article_table()
  end

  defmacro migrate_article() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(ma(:up)),
        else: unquote(ma(:down))
    end
  end
  defmacro migrate_article(dir), do: ma(dir)

end
