require "active_support/all"
require 'nokogiri'
require 'open-uri'

module Helpers
  extend ActiveSupport::NumberHelper
end

module Jekyll
  class GoogleScholarCitationsTag < Liquid::Tag
    Citations = { }
    
    # Array of realistic User-Agent strings to rotate through
    USER_AGENTS = [
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15",
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0"
    ]

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
            puts "Citation count for #{article_id} already cached: #{GoogleScholarCitationsTag::Citations[article_id]}"
            return GoogleScholarCitationsTag::Citations[article_id]
          end

          puts "Fetching citation count for article #{article_id}..."
          puts "URL: #{article_url}"

          # Sleep for a longer random amount of time to avoid being blocked
          sleep_time = rand(3.0..8.0)
          puts "Sleeping for #{sleep_time.round(2)} seconds..."
          sleep(sleep_time)

          citation_count = fetch_citation_count_with_retry(article_url, article_id, max_retries: 3)

        citation_count = Helpers.number_to_human(citation_count, :format => '%n%u', :precision => 2, :units => { :thousand => 'K', :million => 'M', :billion => 'B' })

      rescue Exception => e
        # Handle any errors that may occur during fetching
        citation_count = "N/A"

        # Print the error message including the exception class and message
        puts "Error fetching citation count for #{article_id}: #{e.class} - #{e.message}"
        puts "Backtrace: #{e.backtrace.first(3).join(', ')}" if e.backtrace
      end

      GoogleScholarCitationsTag::Citations[article_id] = citation_count
      puts "Final citation count for #{article_id}: #{citation_count}"
      return "#{citation_count}"
    end

    private

    def fetch_citation_count_with_retry(article_url, article_id, max_retries: 3)
      retries = 0
      
      while retries < max_retries
        begin
          puts "Attempt #{retries + 1}/#{max_retries} for article #{article_id}"
          
          # Rotate through different User-Agent strings
          user_agent = USER_AGENTS[retries % USER_AGENTS.length]
          puts "Using User-Agent: #{user_agent}"
          
          # Create more realistic headers
          headers = {
            "User-Agent" => user_agent,
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
            "Accept-Language" => "en-US,en;q=0.9",
            "Accept-Encoding" => "gzip, deflate, br",
            "DNT" => "1",
            "Connection" => "keep-alive",
            "Upgrade-Insecure-Requests" => "1",
            "Sec-Fetch-Dest" => "document",
            "Sec-Fetch-Mode" => "navigate",
            "Sec-Fetch-Site" => "none",
            "Cache-Control" => "max-age=0"
          }
          
          puts "Requesting URL with headers..."
          doc = Nokogiri::HTML(URI.open(article_url, headers))
          puts "Successfully fetched page, parsing..."

          # Attempt to extract the citation count from the link text
          citation_count = 0
          
          # Try multiple approaches to find the "Cited by" link
          # Method 1: Use XPath to find links containing "Cited by"
          cited_by_link = doc.at_xpath('//a[contains(text(), "Cited by")]')
          
          # Method 2: If XPath fails, search through all links
          if cited_by_link.nil?
            puts "XPath method failed, trying CSS method..."
            doc.css('a').each do |link|
              if link.text && link.text.include?("Cited by")
                cited_by_link = link
                break
              end
            end
          end

          if cited_by_link
            puts "Found citation link: #{cited_by_link.text}"
            matches = cited_by_link.text.match(/Cited by (\d+[,\d]*)/)
            if matches
              citation_count = matches[1].delete(',').to_i
              puts "Extracted citation count: #{citation_count}"
              return citation_count
            else
              puts "No matches found in citation link text"
            end
          else
            puts "No citation link found"
            # Debug: Show some links to understand the page structure
            puts "Sample links found on page:"
            doc.css('a').first(5).each_with_index do |link, index|
              puts "  [#{index}] #{link.text&.strip} (href: #{link['href']})"
            end
          end

          return citation_count

        rescue OpenURI::HTTPError => e
          retries += 1
          puts "HTTP Error on attempt #{retries}: #{e.message}"
          
          if retries < max_retries
            # Exponential backoff with jitter
            wait_time = (2 ** retries) + rand(1..5)
            puts "Retrying in #{wait_time} seconds..."
            sleep(wait_time)
          else
            puts "Max retries reached, giving up"
            raise e
          end
        rescue => e
          puts "Unexpected error: #{e.class} - #{e.message}"
          raise e
        end
      end
      
      return 0
    end
  end
end

Liquid::Template.register_tag('google_scholar_citations', Jekyll::GoogleScholarCitationsTag)
