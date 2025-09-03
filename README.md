# InviteTool

An Elixir-based automation tool for inviting GitHub users to an organization from issues created in a repository.  
The tool parses unstructured issue text, extracts access request details using an LLM, and manages invites and team assignments through GitHub’s API.  

---

## ✨ Features

- Parse unstructured issue text with **Gemini 2.5 Flash** via the [Instructor](https://github.com/thmsmlr/instructor_ex) library.  
- Strongly typed **AccessRequest schema** ensures structured parsing of role, username, email, and team.  
- Invite users to the GitHub organization using the GitHub REST API.  
- (Bonus) Automatically assign invited users to org teams.  
- Source control invites by creating a PR with a YAML invite file (no git CLI, direct GitHub API).  
- Packaged into a **stand-alone binary** using [Burrito](https://github.com/burrito-elixir/burrito) — no Erlang runtime required.  
- Distributed through **GitHub Releases** and consumed by a **GitHub Action**.  
- Handles only the triggering issue (`issues:opened`) event.  

## 🛠️ Development

### Prerequisites
- Elixir `>= 1.17`
- OTP `>= 26`
- [Burrito](https://hexdocs.pm/burrito)
- [Instructor](https://hex.pm/packages/instructor)

### Setup
```bash
# Clone the repo
git clone https://github.com/omarnabil1998/Invite-Users-Tool.git
cd invite_tool

# Install the dependencies
mix deps.get

# To run locally
mix run -- test.txt

# To produce portable binaries
MIX_ENV=prod mix release