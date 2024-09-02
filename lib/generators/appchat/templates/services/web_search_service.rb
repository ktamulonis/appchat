require 'watir'
require 'cgi'

class WebSearchService
  attr_reader :query

  def initialize(args)
    @query = args["query"]
  end

  def run
    yield("Searching Google for #{@query}") if block_given?

    browser = Watir::Browser.new :chrome, headless: true
    search_url = "https://www.google.com/search?q=#{CGI.escape(query)}"
    browser.goto(search_url)
    response = "browser_text: #{browser.text} browser_links: #{browser.links}"
    browser.close
    response
  rescue Selenium::WebDriver::Error::UnknownError => e
    "Error: #{e.message}"
  end
end
