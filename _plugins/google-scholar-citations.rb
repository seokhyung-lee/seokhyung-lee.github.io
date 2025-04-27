require "active_support/all"
require 'nokogiri'
require 'open-uri'

module Helpers
  extend ActiveSupport::NumberHelper
end

module Jekyll
  class GoogleScholarCitationsTag < Liquid::Tag
    Citations = { }

    def initialize(tag_name, params, tokens)
      super
      splitted = params.split(" ").map(&:strip)
      @scholar_id = splitted[0]
      @article_id = splitted[1]
    end

    def render(context)
      article_id = context[@article_id.strip]
      scholar_id = context[@scholar_id.strip]
      article_url = "https://scholar.google.com/citations?view_op=view_citation&hl=en&user=#{scholar_id}&citation_for_view=#{scholar_id}:#{article_id}"

      begin
          # If the citation count has already been fetched, return it
          if GoogleScholarCitationsTag::Citations[article_id]
            return GoogleScholarCitationsTag::Citations[article_id]
          end

          # Sleep for a random amount of time to avoid being blocked
          sleep(rand(1.5..3.5))

          # Fetch the article page
          # Use a common browser User-Agent to avoid being blocked
          user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36"
          doc = Nokogiri::HTML(URI.open(article_url, "User-Agent" => user_agent))

          # Attempt to extract the citation count from the link text
          citation_count = 0
          cited_by_link = doc.at_css('a:contains("Cited by")')

          if cited_by_link
            matches = cited_by_link.text.match(/Cited by (\d+[,\d]*)/)
            if matches
              citation_count = matches[1].delete(',').to_i
            end
          end

        citation_count = Helpers.number_to_human(citation_count, :format => '%n%u', :precision => 2, :units => { :thousand => 'K', :million => 'M', :billion => 'B' })

      rescue Exception => e
        # Handle any errors that may occur during fetching
        citation_count = "N/A"

        # Print the error message including the exception class and message
        puts "Error fetching citation count for #{article_id}: #{e.class} - #{e.message}"
      end


      GoogleScholarCitationsTag::Citations[article_id] = citation_count
      return "#{citation_count}"
    end
  end
end

Liquid::Template.register_tag('google_scholar_citations', Jekyll::GoogleScholarCitationsTag)
