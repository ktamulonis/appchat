class Message < ApplicationRecord
  include ActionView::RecordIdentifier
  belongs_to :chat
  has_many :function_logs, dependent: :destroy

  after_create_commit :broadcast_message
  after_update_commit :broadcast_update_message
  
  def broadcast_update_message
    broadcast_replace_to dom_id(chat, :messages), target: dom_id(self), partial: "messages/message", locals: { message: self }
  end

  def broadcast_message
    broadcast_append_to dom_id(chat, :messages), target: "chat-messages", partial: "messages/message", locals: { message: self }
  end
end
