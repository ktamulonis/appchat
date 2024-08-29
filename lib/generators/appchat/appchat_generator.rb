require 'rails/generators'
require 'rails/generators/migration'
require 'bundler'

class AppchatGenerator < Rails::Generators::Base
  include Turbo::FramesHelper, ActionView::Helpers::TagHelper, 
  ActionView::Helpers::FormTagHelper, ActionView::Helpers::FormHelper, 
  Rails.application.routes.url_helpers
  source_root File.expand_path('templates', __dir__)

  def add_gems
    unless gem_exists?('ollama-ai')
      append_to_file 'Gemfile', "\ngem 'ollama-ai'\n"
    end

    unless gem_exists?('tailwindcss-rails')
      append_to_file 'Gemfile', "\ngem 'tailwindcss-rails'\n"
    end

    Bundler.with_unbundled_env do
      run 'bundle install'
    end
    run 'rails tailwindcss:install'
  end

  def set_routes
    route "resources :chats"
    route "resources :messages"
  end

  def generate_models
    generate "model", "Chat context:text"
    generate "model", "Message chat:references content:text role:integer"
  end

  def create_controllers
    copy_file "chats_controller.rb", "app/controllers/chats_controller.rb"
    copy_file "messages_controller.rb", "app/controllers/messages_controller.rb", force: true
  end

  def create_views
    copy_file "chats/chat.html.erb", "app/views/chats/_chat.html.erb", force: true
    copy_file "chats/index.html.erb", "app/views/chats/index.html.erb", force: true
    copy_file "chats/show.html.erb", "app/views/chats/show.html.erb", force: true
    copy_file "messages/index.html.erb", "app/views/messages/index.html.erb", force: true
    copy_file "messages/new.html.erb", "app/views/messages/new.html.erb", force: true
    copy_file "messages/message.html.erb", "app/views/messages/_message.html.erb", force: true
    copy_file "messages/_typing_bubbles.html.erb", "app/views/messages/_typing_bubbles.html.erb", force: true
  end

  def create_stylesheets
    copy_file "assets/appchat.tailwind.css", "app/assets/stylesheets/appchat.tailwind.css", force: true
  end

  def create_stimulus_controllers
    copy_file "javascript/chat_message_controller.js", "app/javascript/controllers/chat_message_controller.js"
    copy_file "javascript/speech_to_text_controller.js", "app/javascript/controllers/speech_to_text_controller.js"
  end

  def copy_models
    copy_file "models/message.rb", "app/models/message.rb", force: true
    copy_file "models/chat.rb", "app/models/chat.rb", force: true
  end

  def serialize_context
    inject_into_class 'app/models/chat.rb', 'Chat', "serialize :context, coder:JSON, type: Array\n"
  end

  def set_associations
    inject_into_class 'app/models/chat.rb', 'Chat', "  has_many :messages, dependent: :destroy\n"
  end

  def run_migrations
    rake "db:migrate"
  end

  def create_background_job
    copy_file "get_ai_response_job.rb", "app/jobs/get_ai_response_job.rb"
  end

  def swap_class_in_layout
    layout_file = "app/views/layouts/application.html.erb"

    if File.exist?(layout_file)
      gsub_file layout_file, /\bmt-28\b/, "mt-10"
    else
      say "Layout file not found. No changes were made.", :red
    end
  end

  def show_art
    puts <<-ART
  
                            _             _   
                           | |           | |  
  __ _  _ __   _ __    ___ | |__    __ _ | |_ 
 / _` || '_ \ | '_ \  / __|| '_ \  / _` || __|
| (_| || |_) || |_) || (__ | | | || (_| || |_ 
 \__,_|| .__/ | .__/  \___||_| |_| \__,_| \__|
       | |    | |                             
       |_|    |_|                             
  
    ART
  end

  def get_started
    puts "Congratulations on setting up appchat! \n run bin/dev to spin up your app, and visit localhost:3000/chats to start chatting"
  end

  private

  def gem_exists?(gem_name)
    File.read('Gemfile').include? gem_name
  end
end

