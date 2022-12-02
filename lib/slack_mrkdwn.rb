# frozen_string_literal: true
# thank you to the author! https://github.com/BlazingBBQ/SlackMrkdwn
require 'redcarpet'

class SlackMrkdwn < Redcarpet::Render::Base
  class << self
    def from(markdown)
      renderer = SlackMrkdwn.new
      Redcarpet::Markdown.new(renderer, strikethrough: true, underline: true, fenced_code_blocks: true).render(markdown)
    end
  end

  # Methods where the first argument is the text content
  [
    # block-level calls
    :block_html,

    :autolink,
    :raw_html,

    :table, :table_row, :table_cell,

    :superscript, :highlight,

    # footnotes
    :footnotes, :footnote_def, :footnote_ref,

    :hrule,

    # low level rendering
    :entity, :normal_text,

    :doc_header, :doc_footer,
  ].each do |method|
    define_method method do |*args|
      args.first
    end
  end

  # Encode Slack restricted characters
  def preprocess(content)
    content.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
  end

  def postprocess(content)
    content.rstrip
  end

  # ~~strikethrough~~
  def strikethrough(content)
    "~#{content}~"
  end

  # _italic_
  def underline(content)
    "_#{content}_"
  end

  # *italic*
  def emphasis(content)
    "_#{content}_"
  end

  # **bold**
  def double_emphasis(content)
    "*#{content}*"
  end

  # ***bold and italic***
  def triple_emphasis(content)
    "*_#{content}_*"
  end

  # ``` code block ```
  def block_code(content, _language)
    "```\n#{content}```\n\n"
  end

  # > quote
  def block_quote(content)
    "&gt; #{content}"
  end

  # `code`
  def codespan(content)
    "`#{content}`"
  end

  # links
  def link(link, _title, content)
    "<#{link}|#{content}>"
  end

  # list. Called when all list items have been consumed
  def list(entries, style)
    entries = format_list(entries, style)
    remember_last_list_entries(entries)
    entries
  end

  # list item
  def list_item(entry, _style)
    if @last_entries && entry.end_with?(@last_entries)
      entry = indent_list_items(entry)
      @last_entries = nil
    end
    entry
  end

  # ![](image)
  def image(url, _title, _content)
    link(url, _title, File.basename(url))
  end

  def paragraph(text)
    pre_spacing = @last_entries ? "\n" : nil
    clear_last_list_entries
    "#{pre_spacing}#{text}\n\n"
  end

  # # Header
  def header(text, _header_level)
    "*#{text}*\n"
  end

  def linebreak()
    "\n"
  end

  private

  def format_list(entries, style)
    case style
    when :ordered
      number_list(entries)
    when :unordered
      add_dashes(entries)
    end
  end

  def add_dashes(entries)
    entries.gsub(/^(\S+.*)$/, '- \1')
  end

  def number_list(entries)
    count = 0
    entries.gsub(/^(\S+.*)$/) do
      match = Regexp.last_match
      count += 1
      "#{count}. #{match[0]}"
    end
  end

  def remember_last_list_entries(entries)
    @last_entries = entries
  end

  def clear_last_list_entries
    @last_entries = nil
  end

  def nest_list_entries(entries)
    entries.gsub(/^(.+)$/, '   \1')
  end

  def indent_list_items(entry)
    entry.gsub(@last_entries, nest_list_entries(@last_entries))
  end
end