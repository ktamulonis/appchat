class ChatsController < ApplicationController
  def show
    @chat = Chat.find(params[:id])
  end
  def index
    @chats = Chat.all.reverse
  end
  def create
    @chat = Chat.create
    redirect_to @chat
  end
end
