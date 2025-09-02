defmodule InviteTool.GitHub do
  @api "https://api.github.com"

  def create_invite_pr(%InviteTool.Schema.AccessRequest{} = req) do
    github_token = Application.fetch_env!(:invite_tool, :github)[:github_token]
    github_repo = Application.fetch_env!(:invite_tool, :github)[:github_repo]

    branch = "invite-#{req.username}"
    path = "invites/#{req.username}.yaml"

    content = """
    username: #{req.username}
    email: #{req.email}
    role: #{req.role}
    """

    client = Req.new(base_url: @api, auth: {:bearer, github_token})

    %{"object" => %{"sha" => base_sha}} =
      client |> Req.get!(url: "/repos/#{github_repo}/git/ref/heads/master") |> Map.fetch!(:body)

    client
    |> Req.post!(
      url: "/repos/#{github_repo}/git/refs",
      json: %{
        ref: "refs/heads/#{branch}",
        sha: base_sha
      }
    )

    %{"sha" => blob_sha} =
      client
      |> Req.post!(
        url: "/repos/#{github_repo}/git/blobs",
        json: %{
          content: content,
          encoding: "utf-8"
        }
      )
      |> Map.fetch!(:body)

    %{"sha" => tree_sha} =
      client
      |> Req.post!(
        url: "/repos/#{github_repo}/git/trees",
        json: %{
          base_tree: base_sha,
          tree: [
            %{
              path: path,
              mode: "100644",
              type: "blob",
              sha: blob_sha
            }
          ]
        }
      )
      |> Map.fetch!(:body)

    %{"sha" => commit_sha} =
      client
      |> Req.post!(
        url: "/repos/#{github_repo}/git/commits",
        json: %{
          message: "Invite #{req.username}",
          tree: tree_sha,
          parents: [base_sha]
        }
      )
      |> Map.fetch!(:body)

    client
    |> Req.patch!(
      url: "/repos/#{github_repo}/git/refs/heads/#{branch}",
      json: %{sha: commit_sha, force: true}
    )

    client
    |> Req.post!(
      url: "/repos/#{github_repo}/pulls",
      json: %{
        title: "Invite #{req.username}",
        head: branch,
        base: "master",
        body: "This PR invites #{req.username} (#{req.email}) as #{req.role}."
      }
    )
  end

  def invite_user(req) do
    github_token = Application.fetch_env!(:invite_tool, :github)[:github_token]
    github_org = Application.fetch_env!(:invite_tool, :github)[:github_org]

    client = Req.new(base_url: @api, auth: {:bearer, github_token})

    client
    |> Req.post!(
      url: "/orgs/#{github_org}/invitations",
      json: %{
        invitee_id: fetch_user_id(client, req.username),
        role: req.role
      }
    )
  end

  defp fetch_user_id(client, username) do
    %{"id" => id} =
      client
      |> Req.get!(url: "/users/#{username}")
      |> Map.fetch!(:body)

    id
  end
end
