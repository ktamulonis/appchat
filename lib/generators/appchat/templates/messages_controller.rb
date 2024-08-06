class MessagesController < ApplicationController
  before_action :set_chat

  def new
    @message = @chat.messages.new
  end  

  def create
    @message = @chat.messages.build(message_params)
    if @message.save
      GetAiResponseJob.perform_later(@message.chat_id, @message.content)
      redirect_to new_message_path(chat_id: @chat.id), notice: 'Message was successfully created.'
    else
      render :new
    end
  end

  def index
    @messages = @chat.messages
  end

  private

  def set_chat
    @chat = Chat.find(params[:chat_id])
  end

  def message_params
    params.require(:message).permit(:content, :role)
  end
end

