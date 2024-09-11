require 'rails/generators'
require 'rails/generators/migration'
require 'bundler'

class AppchatGenerator < Rails::Generators::Base
  include Turbo::FramesHelper, ActionView::Helpers::TagHelper, 
  ActionView::Helpers::FormTagHelper, ActionView::Helpers::FormHelper, 
  Rails.application.routes.url_helpers
  source_root File.expand_path('templates', __dir__)

  def add_gems
    gems = %w(
      ollama-ai
      tailwindcss-rails
    )

    gems.each do |gem|
      unless gem_exists?(gem)
        append_to_file 'Gemfile', "\ngem '#{gem}'\n"
      end
    end

    Bundler.with_unbundled_env do
      run 'bundle install'
    end
  end

  def install_tailwind
    run 'rails tailwindcss:install'
  end

  def set_routes
    route "resources :chats"
    route "resources :messages"
  end

  def generate_models
    generate "model", "Chat context:text"
    generate "model", "Message chat:references content:text role:integer status:string"
    generate "model", "AppchatFunction name:string description:text class_name:string"
    generate "model", "FunctionParameter appchat_function:references name:string example_value:string"
    generate "model", "FunctionLog message:references name:string prompt:text results:text"
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
    copy_file "messages/_function_logs.html.erb", "app/views/messages/_function_logs.html.erb", force: true
  end

  def create_stylesheets
    copy_file "assets/appchat.tailwind.css", "app/assets/stylesheets/appchat.tailwind.css", force: true
  end

  def create_stimulus_controllers
    copy_file "javascript/chat_message_controller.js", "app/javascript/controllers/chat_message_controller.js"
    copy_file "javascript/speech_to_text_controller.js", "app/javascript/controllers/speech_to_text_controller.js"
    copy_file "javascript/toggle_controller.js", "app/javascript/controllers/toggle_controller.js"
  end

  def copy_models
    copy_file "models/message.rb", "app/models/message.rb", force: true
    copy_file "models/chat.rb", "app/models/chat.rb", force: true
    copy_file "models/appchat_function.rb", "app/models/appchat_function.rb", force: true
  end

  def copy_services
    copy_file "services/appchat_function_service.rb", "app/services/appchat_function_service.rb", force: true
    copy_file "services/web_search_service.rb", "app/services/web_search_service.rb", force: true
  end

  def serialize_context
    inject_into_class 'app/models/chat.rb', 'Chat', "serialize :context, coder:JSON, type: Array\n"
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

  def copy_rake_tasks
    copy_file "tasks/create_appchat_function.rake", "lib/tasks/create_appchat_function.rake"
  end

  def create_functions
    rake "appchat_function:create_web_search"
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

