require 'cgi'
require 'open-uri'

class WebSearchService
  attr_reader :query
  def initialize(args)
    @query = args["query"]
  end

  def run
    yield("Searching Google for #{query}")

    doc = Nokogiri::HTML(URI.open("https://www.google.com/search?q=#{CGI.escape(query)}").read.force_encoding('UTF-8'))
    doc.css('script, style, noscript, comment').remove
    doc.css('h1, h2, h3, h4, h5, h6, p').map(&:text).join("\n").strip
  end
end
