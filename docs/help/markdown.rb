# frozen_string_literal: true

require "nokogiri"
require "redcarpet"

module Docs
  MARKDOWN_OPTIONS = {
    autolink: true, fenced_code_blocks: true, no_intra_emphasis: true,
    space_after_headers: true, strikethrough: true, superscript: true,
    tables: true, underline: true
  }.freeze

  # Compare rendered Markdown contracts rather than paragraph boundaries:
  # translators may split prose and reorder links to suit their language.
  module Markdown
    # Migration formatting: unwrap ordinary prose, preserving Markdown blocks,
    # explicit hard breaks and sections containing literal fenced examples.
    def self.prose_unwrap(text)
      return text if text.include?("```") || text.include?("~~~")

      text.gsub(/(?:\A|(?<=\n\n))(.+?)(?=\n\n|\z)/m) do |block|
        structural = block.lines.any? { |line| line.match?(/\A(?: {4}|\t|\s*(?:\#{1,6}\s|[-*+]\s|\d+[.)]\s|[>|<]|!\[))/) }
        structural || block.match?(/ {2}\n|\\\n/) ? block : block.gsub(/\n\s*/, " ")
      end
    end

    class Renderer < Redcarpet::Render::HTML
      attr_reader :literal_html

      def initialize
        super
        @literal_html = []
      end

      def block_html(html)
        @literal_html << html unless html.strip.start_with?("<!--")
        html
      end

      def raw_html(html)
        @literal_html << html
        html
      end
    end

    def self.contract(text)
      renderer = Renderer.new
      fragment = Nokogiri::HTML5.fragment(Redcarpet::Markdown.new(renderer, MARKDOWN_OPTIONS).render(text))
      {
        "link targets" => fragment.css("a[href]").map { |node| node["href"] }.tally,
        "image targets" => fragment.css("img[src]").map { |node| node["src"] }.tally,
        "code" => fragment.css("code").map(&:text).tally,
        "HTML" => renderer.literal_html.tally,
        "heading levels" => fragment.css("h1, h2, h3, h4, h5, h6").map(&:name),
        "lists" => fragment.css("ul, ol").map { |node| [node.name, node["start"], node.element_children.count { |child| child.name == "li" }] },
        "tables" => fragment.css("tr").map { |node| node.element_children.map(&:name) },
        "alert markers" => text.scan(/\[![A-Z]+\]/).tally,
        "summary comments" => text.scan(/<!--\s*seo-description:/).length
      }
    end

    def self.errors(english, translation)
      source = contract(english)
      target = contract(translation)
      source.filter_map { |name, value| "#{name} differ from the English" unless target.fetch(name) == value }
    end
  end
end
