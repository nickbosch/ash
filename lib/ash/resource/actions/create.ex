defmodule Ash.Resource.Actions.Create do
  @moduledoc "The representation of a `create` action."
  defstruct [:type, :name, :primary?, :rules]

  @type t :: %__MODULE__{
          type: :create,
          name: atom,
          primary?: boolean,
          rules: Authorizer.steps()
        }

  @opt_schema Ashton.schema(
                opts: [
                  primary?: :boolean,
                  rules: :keyword
                ],
                defaults: [
                  primary?: false,
                  rules: []
                ],
                describe: [
                  primary?:
                    "Whether or not this action should be used when no action is specified by the caller.",
                  # TODO: doc better
                  rules: "A list of authorization steps"
                ]
              )

  @doc false
  def opt_schema(), do: @opt_schema

  @spec new(Ash.resource(), atom, Keyword.t()) :: {:ok, t()} | {:error, term}
  def new(resource, name, opts \\ []) do
    case Ashton.validate(opts, @opt_schema) do
      {:ok, opts} ->
        rules =
          case opts[:rules] do
            false ->
              false

            steps ->
              base_attribute_opts = [
                resource: resource
              ]

              Enum.map(steps, fn {step, {mod, opts}} ->
                {step, {mod, Keyword.merge(base_attribute_opts, opts)}}
              end)
          end

        {:ok,
         %__MODULE__{
           name: name,
           type: :create,
           primary?: opts[:primary?],
           rules: rules
         }}

      {:error, error} ->
        {:error, error}
    end
  end
end
