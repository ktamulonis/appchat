class GetAiResponseJob < ApplicationJob
  queue_as :default

  attr_reader :client, :chat, :user_prompt, :informed_prompt, :message

  def perform(chat_id, user_prompt)
    @client = new_client
    @chat = Chat.find(chat_id)
    @user_prompt = user_prompt
    @message = chat.messages.create(role: 'assistant')
    appchat_functions
    call_ollama
  end

  private

  def new_client
    Ollama.new(
      credentials: { address: 'http://localhost:11434' },
      options: { server_sent_events: true }
    )
  end

  def call_ollama
    prompt = informed_prompt || user_prompt

    response = client.generate(
      {
        model: 'llama3.1',
        prompt: prompt,
        context: chat.context,
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
    chat.update(context: response.last["context"])
  end

  def appchat_functions
    appchat_function_service = AppchatFunctionService.new(chat.id, user_prompt).run
    if appchat_function_service["match"] == "true" && appchat_function_service["appchat_function"].in?(AppchatFunction.pluck(:class_name))
      puts "Function Match Found! --> #{appchat_function_service}"
      function_class = appchat_function_service["appchat_function"].constantize
      function_response = function_class.new(appchat_function_service["parameters"]).run do |status|
        message.update(status: status)
      end

      return if function_response.nil?
      @informed_prompt = "#{ user_prompt }, base your response on this data:
        #{ appchat_function_service["name"] } responded with: #{ function_response },
        :current_time => #{Date.current}"
    end
  end
end
