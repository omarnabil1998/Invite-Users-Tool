defmodule InviteTool do
  use Application
  alias InviteTool.Parser

  @impl true
  def start(_type, _args) do
    args = Burrito.Util.Args.argv()

    case args do
      [file_path] ->
        case File.read(file_path) do
          {:ok, issue_text} ->
            run(issue_text)
            System.halt(0)

          {:error, reason} ->
            IO.puts("Failed to read file")
            System.halt(1)
        end

      _ ->
        IO.puts("Usage: invite_tool <file_path>")
        System.halt(1)
    end
  end

  def run(issue_text) do
    case Parser.parse_issue_text(issue_text) do
      {:ok, access_request} ->
        IO.puts("Parsed request: #{inspect(access_request)}")

      {:error, reason} ->
        IO.puts("Failed to parse issue: #{inspect(reason)}")
    end
  end
end
