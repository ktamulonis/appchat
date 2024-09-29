class AppchatFunctionService
  attr_reader :chat, :user_prompt, :response_json

  def initialize(chat_id, user_prompt)
    @chat = Chat.find(chat_id)
    @user_prompt = user_prompt
  end

  def run
    call_ollama
    response_json
  end

  def call_ollama
    client = Ollama.new(
      credentials: { address: 'http://localhost:11434' },
      options: { server_sent_events: true }
    )
    response = client.generate(
      {
        model: 'llama3.2',
        prompt: prompt,
        context: chat.context,
        "format": "json"
      }
    )
    @response_json = JSON.parse(response.map { |r| r["response"] }.join)
  end
  def prompt
    <<-PROMPT
      Evaluate the following user prompt in chat context.
      Your goal is to determine whether the user prompt is requesting or requires additional information from any of the available services.
        - If the prompt is a general greeting, casual remark, or something that can be answered without further information, respond with JSON { 'match' => 'false' }.
        - If the prompt asks for specific information, requires a search, or needs a service to generate the correct response, then respond with JSON like this example:
        {
          'match' => 'true',
          'appchat_function' => 'WebSearchService',
          'parameters' => {
            'query' => 'a query based on the prompt and context'
          }
        }

      Here is the user's prompt: #{user_prompt}
      Here are the Available Services: #{ AppchatFunction.all_to_prompt_json }
    PROMPT
  end
end
