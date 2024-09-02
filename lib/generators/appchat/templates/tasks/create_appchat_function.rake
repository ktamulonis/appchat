# lib/tasks/create_appchat_function.rake
namespace :appchat_function do
  desc "Create an AppchatFunction with name 'Web Search', class name 'WebSearchService', and a description"
  task create_web_search: :environment do
    af = AppchatFunction.create!(
      name: "Web Search",
      class_name: "WebSearchService",
      description: "Searches Google with a user's query and returns the page text and links"
    )
    puts "AppchatFunction 'Web Search' created successfully."
    af.function_parameters.create(name: 'query', example_value: 'Dog friendly vegan resturants in Austin, TX')
  end
end
