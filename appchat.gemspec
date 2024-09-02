Gem::Specification.new do |s|
  s.name        = "appchat"
  s.version     = "0.0.6"
  s.summary     = "Appchat makes it easy to add an AI chat to your app"
  s.description = "The best and easiest framework for adding AI chats"
  s.authors     = ["hackliteracy"]
  s.email       = "hackliteracy@gmail.com"
  s.metadata["source_code_uri"] = 'https://github.com/ktamulonis/appchat'
  s.files       = Dir["lib/**/*.rb"] + Dir["lib/generators/appchat/**/*"]
  s.homepage    = "https://rubygems.org/gems/appchat"
  s.license     = "MIT"

  s.add_development_dependency "bundler", "~> 2.0"
  s.add_development_dependency "rake", "~> 12.0"
  s.add_runtime_dependency "rails", ">= 6.0" 
  s.add_runtime_dependency "ollama-ai", "~> 1.3.0" 
  s.required_ruby_version = ">= 3.0"
end

