# copied from https://edruder.com/blog/2017/12/19/add-markdown-to-rails-5
require 'redcarpet'
require 'loofah'

# give headings an id
class LoomioMarkdown < Redcarpet::Render::HTML
  def header(text, header_level)
    "<h#{header_level} id='#{text[0,60].strip.parameterize}'>#{text}</h#{header_level}>"
  end

  # Redcarpet's HTML filtering only applies to literal input tags. Validate the
  # URLs it generates from Markdown so encoded or obfuscated schemes cannot
  # become executable attributes in server-rendered pages and emails.
  def postprocess(document)
    fragment = Nokogiri::HTML5::DocumentFragment.parse(document)
    was_changed = false

    fragment.css('[href], [src]').each do |node|
      %w[href src].each do |attribute|
        next unless node[attribute]
        next if Loofah::HTML5::Scrub.allowed_uri?(node[attribute])

        node[attribute] = '#'
        was_changed = true
      end
    end

    was_changed ? fragment.to_html : document
  end
end

module ActionView
  module Template::Handlers
    class Markdown
      class_attribute :default_format
      self.default_format = Mime[:html]

      class << self
        def call(template)
          compiled_source = erb.call(template)
          "#{name}.render(begin;#{compiled_source};end)"
        end

        def render(template)
          markdown.render(template).html_safe
        end

        private

        def md_options
          @md_options ||= {
            no_intra_emphasis: true,
            underline: true,
            highlight: true,
            autolink: true,
            fenced_code_blocks: true,
            strikethrough: true,
            tables: true
          }
        end

        def markdown
          # @markdown ||= Redcarpet::Markdown.new(HTMLWithPants.new(hard_wrap: true), md_options)
          @markdown ||= Redcarpet::Markdown.new(LoomioMarkdown.new(hard_wrap: true), md_options)
        end

        def erb
          @erb ||= ActionView::Template.registered_template_handler(:erb)
        end
      end
    end
  end
end

ActionView::Template.register_template_handler(:md, ActionView::Template::Handlers::Markdown)
