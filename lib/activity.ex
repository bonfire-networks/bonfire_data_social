defmodule Bonfire.Data.Social.Activity do
  use Needle.Mixin,
    otp_app: :bonfire_data_social,
    # table_id: "1TSASVBJECTVERB1NGAN0BJECT",
    source: "bonfire_data_social_activity"

  alias Bonfire.Data.AccessControl.Verb
  alias Bonfire.Data.Social.Activity
  alias Ecto.Changeset
  alias Needle.Pointer
  # use Bonfire.Common.Utils, only: [debug: 2]

  mixin_schema do
    # the who (eg. a user)
    belongs_to(:subject, Pointer)

    # what kind of action (eg. Like, Follow, ...)
    belongs_to(:verb, Verb)

    # the what (eg. a specific post)
    belongs_to(:object, Pointer)
  end

  @cast [:subject_id, :object_id, :verb_id]
  # so we can cast_assoc from object
  @required [:subject_id, :verb_id]

  # note: this is intended to be called by Bonfire.Social.Activities
  # which casts the appropriate data into the parent changeset before
  # calling.
  def changeset(activity \\ %Activity{}, params) do
    activity
    |> Changeset.cast(params, @cast)
    |> Changeset.validate_required(@required)
    |> Changeset.assoc_constraint(:subject)
    |> Changeset.assoc_constraint(:object)
    |> Changeset.assoc_constraint(:verb)
    |> Changeset.cast_assoc(:feed_publishes)
    |> Changeset.unique_constraint(@cast)
  end
end

defmodule Bonfire.Data.Social.Activity.Migration do
  @moduledoc false
  use Ecto.Migration
  import Needle.Migration
  alias Bonfire.Data.Social.Activity

  @activity_table Activity.__schema__(:source)

  # create_activity_table/{0,1}

  defp make_activity_table(exprs) do
    quote do
      import Needle.Migration

      Needle.Migration.create_mixin_table Bonfire.Data.Social.Activity do
        add_pointer(:subject_id, :strong, Needle.Pointer, null: false)
        add_pointer(:object_id, :strong, Needle.Pointer, null: true)
        add_pointer(:verb_id, :strong, Bonfire.Data.AccessControl.Verb, null: false)

        unquote_splicing(exprs)
      end
    end
  end

  defmacro create_activity_table(), do: make_activity_table([])

  defmacro create_activity_table(do: {_, _, body}),
    do: make_activity_table(body)

  # drop_activity_table/0

  def drop_activity_table(), do: drop_mixin_table(Activity)

  # create_activity_unique_index/{0,1}

  defp make_activity_subject_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(
          unquote(@activity_table),
          [:subject_id],
          unquote(opts)
        )
      )
    end
  end

  defp make_activity_object_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(
          unquote(@activity_table),
          [:object_id],
          unquote(opts)
        )
      )
    end
  end

  defp make_activity_verb_index(opts) do
    quote do
      Ecto.Migration.create_if_not_exists(
        Ecto.Migration.index(
          unquote(@activity_table),
          [:verb_id],
          unquote(opts)
        )
      )
    end
  end

  defmacro create_activity_subject_index(opts \\ [])

  defmacro create_activity_subject_index(opts),
    do: make_activity_subject_index(opts)

  defmacro create_activity_object_index(opts \\ [])

  defmacro create_activity_object_index(opts),
    do: make_activity_subject_index(opts)

  defmacro create_activity_verb_index(opts \\ [])
  defmacro create_activity_verb_index(opts), do: make_activity_verb_index(opts)

  def drop_activity_subject_index(opts \\ []) do
    drop_if_exists(index(@activity_table, [:subject_id], opts))
  end

  def drop_activity_object_index(opts \\ []) do
    drop_if_exists(index(@activity_table, [:object_id], opts))
  end

  def drop_activity_verb_index(opts \\ []) do
    drop_if_exists(index(@activity_table, [:verb_id], opts))
  end

  # migrate_activity/{0,1}

  defp mg(:up) do
    quote do
      unquote(make_activity_table([]))
      unquote(make_activity_subject_index([]))
      unquote(make_activity_object_index([]))
      unquote(make_activity_verb_index([]))
    end
  end

  defp mg(:down) do
    quote do
      Bonfire.Data.Social.Activity.Migration.drop_activity_verb_index()
      Bonfire.Data.Social.Activity.Migration.drop_activity_object_index()
      Bonfire.Data.Social.Activity.Migration.drop_activity_subject_index()
      Bonfire.Data.Social.Activity.Migration.drop_activity_table()
    end
  end

  defmacro migrate_activity() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(mg(:up)),
        else: unquote(mg(:down))
    end
  end

  defmacro migrate_activity(dir), do: mg(dir)
end
