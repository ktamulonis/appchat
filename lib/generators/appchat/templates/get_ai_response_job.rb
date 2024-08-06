class GetAiResponseJob < ApplicationJob
  queue_as :default

  attr_reader :chat, :user_prompt

  def perform(chat_id, user_prompt)
    @chat = Chat.find(chat_id)
    @user_prompt = user_prompt
    call_ollama
  end

  private

  def call_ollama
    client = Ollama.new(
      credentials: { address: 'http://localhost:11434' },
      options: { server_sent_events: true }
    )
    message = chat.messages.create(role: 'assistant')

    response = client.generate(
      {
        model: 'llama3.1',
        prompt: user_prompt,
        stream: true,
      }
     ) do |event, raw|
        if event["response"]
          new_content = ''
          new_content += message.content if message.content
          new_content += event["response"] if event["response"]
          message.update(content: new_content)
        end
      end
  end
end
