defmodule InviteTool.GitHub do
  @api "https://api.github.com"

  def create_invite_pr(%InviteTool.Schema.AccessRequest{} = req) do
    github_repo = Application.fetch_env!(:invite_tool, :github)[:github_repo]

    branch = "invite-#{req.username}"
    path = "invites/#{req.username}.yaml"

    content = """
    username: #{req.username}
    email: #{req.email}
    role: #{req.role}
    team: #{req.team}
    """

    client = github_client()

    IO.puts("[STEP] Fetching base commit SHA from master")

    with {:ok, %{"object" => %{"sha" => base_sha}}} <-
           req_get(client, "/repos/#{github_repo}/git/ref/heads/master"),
         _ <- IO.puts("[STEP] Creating branch #{branch}"),
         {:ok, _ref} <-
           req_post(client, "/repos/#{github_repo}/git/refs", %{
             ref: "refs/heads/#{branch}",
             sha: base_sha
           }),
         _ <- IO.puts("[STEP] Creating blob with invite file"),
         {:ok, %{"sha" => blob_sha}} <-
           req_post(client, "/repos/#{github_repo}/git/blobs", %{
             content: content,
             encoding: "utf-8"
           }),
         _ <- IO.puts("[STEP] Creating tree with blob"),
         {:ok, %{"sha" => tree_sha}} <-
           req_post(client, "/repos/#{github_repo}/git/trees", %{
             base_tree: base_sha,
             tree: [
               %{
                 path: path,
                 mode: "100644",
                 type: "blob",
                 sha: blob_sha
               }
             ]
           }),
         _ <- IO.puts("[STEP] Creating commit"),
         {:ok, %{"sha" => commit_sha}} <-
           req_post(client, "/repos/#{github_repo}/git/commits", %{
             message: "Invite #{req.username}",
             tree: tree_sha,
             parents: [base_sha]
           }),
         _ <- IO.puts("[STEP] Updating branch ref"),
         {:ok, _} <-
           req_patch(client, "/repos/#{github_repo}/git/refs/heads/#{branch}", %{
             sha: commit_sha,
             force: true
           }),
         _ <- IO.puts("[STEP] Creating pull request"),
         {:ok, pr} <-
           req_post(client, "/repos/#{github_repo}/pulls", %{
             title: "Invite #{req.username}",
             head: branch,
             base: "master",
             body: "This PR invites #{req.username} (#{req.email}) as #{req.role}."
           }) do
      IO.puts("[SUCCESS] PR created successfully")
      {:ok, pr}
    else
      {:error, reason} ->
        IO.puts("[FAILURE] #{inspect(reason)}")
        {:error, reason}
    end
  end

  def invite_user(req) do
    client = github_client()
    github_org = Application.fetch_env!(:invite_tool, :github)[:github_org]

    IO.puts("[STEP] Fetching user ID for #{req.username}")

    with {:ok, user_id} <- fetch_user_id(client, req.username),
         _ <- IO.puts("[STEP] Sending organization invite"),
         {:ok, _invite} <- send_invite(client, github_org, user_id, req.role),
         _ <- IO.puts("[STEP] Assigning user to team #{req.team}"),
         {:ok, _team} <- assign_team(client, github_org, req) do
      {:ok, "#{req.username} invited and assigned to team"}
    else
      {:error, reason} ->
        IO.puts("[FAILURE] #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp send_invite(client, github_org, user_id, role) do
    req_post(client, "/orgs/#{github_org}/invitations", %{
      invitee_id: user_id,
      role: role
    })
  end

  defp assign_team(client, github_org, req) do
    req_put(client, "/orgs/#{github_org}/teams/#{req.team}/memberships/#{req.username}")
  end

  defp fetch_user_id(client, username) do
    case Req.get(client, url: "/users/#{username}") do
      {:ok, %{body: %{"id" => id}}} ->
        IO.puts("[SUCCESS] Got user ID #{id} for #{username}")
        {:ok, id}

      {:ok, resp} ->
        IO.puts("[ERROR] Unexpected response while fetching user ID: #{inspect(resp.body)}")
        {:error, "Unexpected response: #{inspect(resp.body)}"}

      {:error, err} ->
        IO.puts("[ERROR] Failed to fetch user ID: #{inspect(err)}")
        {:error, "Failed to fetch user ID: #{inspect(err)}"}
    end
  end

  defp github_client() do
    github_token = Application.fetch_env!(:invite_tool, :github)[:github_token]
    Req.new(base_url: @api, auth: {:bearer, github_token})
  end

  defp req_get(client, url) do
    case Req.get(client, url: url) do
      {:ok, %{status: status, body: body}} ->
        IO.puts("[SUCCESS] GET #{url} -> #{status}")
        IO.inspect(body, label: "[BODY]")
        {:ok, body}

      {:error, err} ->
        IO.puts("[ERROR] GET #{url} failed: #{inspect(err)}")
        {:error, inspect(err)}
    end
  end

  defp req_post(client, url, json) do
    case Req.post(client, url: url, json: json) do
      {:ok, %{status: status, body: body}} ->
        IO.puts("[SUCCESS] POST #{url} -> #{status}")
        IO.inspect(body, label: "[BODY]")
        {:ok, body}

      {:error, err} ->
        IO.puts("[ERROR] POST #{url} failed: #{inspect(err)}")
        {:error, inspect(err)}
    end
  end

  defp req_patch(client, url, json) do
    case Req.patch(client, url: url, json: json) do
      {:ok, %{status: status, body: body}} ->
        IO.puts("[SUCCESS] PATCH #{url} -> #{status}")
        IO.inspect(body, label: "[BODY]")
        {:ok, body}

      {:error, err} ->
        IO.puts("[ERROR] PATCH #{url} failed: #{inspect(err)}")
        {:error, inspect(err)}
    end
  end

  defp req_put(client, url, json \\ %{}) do
    case Req.put(client, url: url, json: json) do
      {:ok, %{status: status, body: body}} ->
        IO.puts("[SUCCESS] PUT #{url} -> #{status}")
        IO.inspect(body, label: "[BODY]")
        {:ok, body}

      {:error, err} ->
        IO.puts("[ERROR] PUT #{url} failed: #{inspect(err)}")
        {:error, inspect(err)}
    end
  end
end
