defmodule InviteTool.Schema.AccessRequest do
  use Ecto.Schema
  use Instructor
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:username, :string)
    field(:email, :string)
    field(:role, :string)
  end

  @llm_doc """
  JSON object representing a GitHub org access request.
  Fields:
    - username: GitHub username (string)
    - email: email of the requester (string)
    - role: github role in the org (string) Can be one of: admin, direct_member, billing_manager, reinstate, (default is : "direct_member")

  The model should extract these fields from unstructured issue text and return
  a JSON object that matches this schema.
  """

  @impl true
  def validate_changeset(schema, attrs) do
    schema
    |> cast(attrs, [:username, :email, :role])
    |> validate_required([:username, :email])
    |> validate_format(:email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/)
  end
end
