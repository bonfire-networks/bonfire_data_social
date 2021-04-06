defmodule Bonfire.Data.Social.Follow do

  use Pointers.Pointable,
    otp_app: :bonfire_data_social,
    table_id: "F0110WTHE1EADER1EADER1EADE",
    source: "bonfire_data_social_follow"

  require Pointers.Changesets
  alias Bonfire.Data.Social.Follow
  alias Ecto.Changeset
  alias Pointers.Pointer

  pointable_schema do
    belongs_to :follower, Pointer
    belongs_to :followed, Pointer
  end

  def context_module() do
    Keyword.get(Application.get_env(:bonfire_data_social, :context_modules), :follow, nil)
  end

  @cast     [:follower_id, :followed_id]
  @required @cast

  def changeset(follow \\ %Follow{}, params) do
    follow
    |> Changeset.cast(params, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.assoc_constraint(:follower)
    |> Changeset.assoc_constraint(:followed)
    |> Changeset.unique_constraint([:follower_id, :followed_id])
  end

end
defmodule Bonfire.Data.Social.Follow.Migration do

  import Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.Social.Follow

  @follow_table Follow.__schema__(:source)
  @unique_index [:follower_id, :followed_id]

  # create_follow_table/{0,1}

  defp make_follow_table(exprs) do
    quote do
      require Pointers.Migration
      Pointers.Migration.create_pointable_table(Bonfire.Data.Social.Follow) do
        Ecto.Migration.add :follower_id,
          Pointers.Migration.strong_pointer(), null: false
        Ecto.Migration.add :followed_id,
          Pointers.Migration.strong_pointer(), null: false
        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_follow_table(), do: make_follow_table([])
  defmacro create_follow_table([do: {_, _, body}]), do: make_follow_table(body)

  # drop_follow_table/0

  def drop_follow_table(), do: drop_pointable_table(Follow)

  # create_follow_unique_index/{0,1}

  defp make_follow_unique_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.unique_index(unquote(@follow_table), unquote(@unique_index), unquote(opts))
      )
    end
  end

  defmacro create_follow_unique_index(opts \\ [])
  defmacro create_follow_unique_index(opts), do: make_follow_unique_index(opts)

  def drop_follow_unique_index(opts \\ [])
  def drop_follow_unique_index(opts), do: drop_if_exists(unique_index(@follow_table, @unique_index, opts))

  defp make_follow_followed_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(unquote(@follow_table), [:followed_id], unquote(opts))
      )
    end
  end

  defmacro create_follow_followed_index(opts \\ [])
  defmacro create_follow_followed_index(opts), do: make_follow_followed_index(opts)

  def drop_follow_followed_index(opts \\ []) do
    drop_if_exists(index(@follow_table, [:followed_id], opts))
  end

  # migrate_follow/{0,1}

  defp mf(:up) do
    quote do
      unquote(make_follow_table([]))
      unquote(make_follow_unique_index([]))
      unquote(make_follow_followed_index([]))
    end
  end
  defp mf(:down) do
    quote do
      Bonfire.Data.Social.Follow.Migration.drop_follow_followed_index()
      Bonfire.Data.Social.Follow.Migration.drop_follow_unique_index()
      Bonfire.Data.Social.Follow.Migration.drop_follow_table()
    end
  end

  defmacro migrate_follow() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mf(:up)),
        else: unquote(mf(:down))
    end
  end

  defmacro migrate_follow(dir), do: mf(dir)

end
