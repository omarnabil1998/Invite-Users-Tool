defmodule InviteTool do
  alias InviteTool.Parser

  def run(issue_text) do
    case Parser.parse_issue_text(issue_text) do
      {:ok, access_request} ->
        IO.puts("Parsed request: #{inspect(access_request)}")

      {:error, reason} ->
        IO.puts("Failed to parse issue: #{inspect(reason)}")
    end
  end
end
