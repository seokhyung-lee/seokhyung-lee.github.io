require "active_support/all"
require 'yaml'

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

      # Get citation count from _data/citations.yml
      citation_count = get_citation_count(scholar_id, article_id)

      if citation_count
        formatted_count = Helpers.number_to_human(citation_count, :format => '%n%u', :precision => 2, :units => { :thousand => 'K', :million => 'M', :billion => 'B' })
        return formatted_count
      end

      return "0"
    end

    private

    def get_citation_count(scholar_id, article_id)
      begin
        site_source = Jekyll.sites.first&.source || Dir.pwd
        citations_file = File.join(site_source, '_data', 'citations.yml')

        return nil unless File.exist?(citations_file)

        citations_data = YAML.load_file(citations_file)
        return nil unless citations_data && citations_data['papers']

        # Try the new format: scholar_id:article_id
        key = "#{scholar_id}:#{article_id}"
        if citations_data['papers'][key]
          return citations_data['papers'][key]['citations']
        end

        # Fallback: search by article_id suffix
        citations_data['papers'].each do |paper_key, paper_data|
          if paper_key.end_with?(":#{article_id}")
            return paper_data['citations']
          end
        end

        nil
      rescue => e
        puts "Error loading citation data: #{e.message}"
        nil
      end
    end
  end
end

Liquid::Template.register_tag('google_scholar_citations', Jekyll::GoogleScholarCitationsTag)
