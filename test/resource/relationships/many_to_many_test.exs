defmodule Ash.Test.Resource.Relationships.ManyToManyTest do
  use ExUnit.Case, async: true

  defmacrop defposts(do: body) do
    quote do
      defmodule Post do
        use Ash.Resource, name: "posts", type: "post", primary_key: false

        unquote(body)
      end
    end
  end

  describe "representation" do
    test "it creates a relationship" do
      defposts do
        relationships do
          many_to_many :foobars, Foobar, through: SomeResource
        end
      end

      assert [
               %Ash.Resource.Relationships.ManyToMany{
                 cardinality: :many,
                 destination: Foobar,
                 destination_field: :id,
                 destination_field_on_join_table: :foobars_id,
                 name: :foobars,
                 source_field: :id,
                 source_field_on_join_table: :posts_id,
                 through: SomeResource,
                 type: :many_to_many
               }
             ] = Ash.relationships(Post)
    end
  end

  describe "validation" do
    test "it fails if you pass a string to `through`" do
      assert_raise(
        Ash.Error.ResourceDslError,
        "option through at relationships -> many_to_many -> foobars must be atom",
        fn ->
          defposts do
            relationships do
              many_to_many :foobars, Foobar, through: "some_table"
            end
          end
        end
      )
    end

    test "you can pass a module to `through`" do
      defposts do
        relationships do
          many_to_many :foobars, Foobar, through: FooBars
        end
      end
    end

    test "it fails if you dont pass an atom for `source_field_on_join_table`" do
      assert_raise(
        Ash.Error.ResourceDslError,
        "option source_field_on_join_table at relationships -> many_to_many -> foobars must be atom",
        fn ->
          defposts do
            relationships do
              many_to_many :foobars, Foobar, through: FooBars, source_field_on_join_table: "what"
            end
          end
        end
      )
    end

    test "it fails if you dont pass an atom for `destination_field_on_join_table`" do
      assert_raise(
        Ash.Error.ResourceDslError,
        "option destination_field_on_join_table at relationships -> many_to_many -> foobars must be atom",
        fn ->
          defposts do
            relationships do
              many_to_many :foobars, Foobar,
                through: FooBar,
                destination_field_on_join_table: "what"
            end
          end
        end
      )
    end

    test "it fails if you dont pass an atom for `source_field`" do
      assert_raise(
        Ash.Error.ResourceDslError,
        "option source_field at relationships -> many_to_many -> foobars must be atom",
        fn ->
          defposts do
            relationships do
              many_to_many :foobars, Foobar,
                through: FooBar,
                source_field: "what"
            end
          end
        end
      )
    end

    test "it fails if you dont pass an atom for `destination_field`" do
      assert_raise(
        Ash.Error.ResourceDslError,
        "option destination_field at relationships -> many_to_many -> foobars must be atom",
        fn ->
          defposts do
            relationships do
              many_to_many :foobars, Foobar,
                through: FooBars,
                destination_field: "what"
            end
          end
        end
      )
    end
  end
end
