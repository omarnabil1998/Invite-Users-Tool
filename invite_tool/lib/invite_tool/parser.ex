defmodule InviteTool.Parser do
  alias InviteTool.Schema.AccessRequest
  alias Instructor

  def parse_issue_text(issue_text) do

    messages = [
      %{role: "user", content: issue_text}
    ]

    Instructor.chat_completion(
      model: "gemini-2.5-flash",
      mode: :json_schema,
      response_model: AccessRequest,
      messages: messages
    )
  end
end
