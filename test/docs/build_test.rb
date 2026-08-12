# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../docs/build"

class DocsBuildTest < Minitest::Test
  def test_renders_github_style_markdown_alerts_with_material_design_icons
    fragment = render_markdown(<<~MARKDOWN)
      > [!WARNING]
      > Once a poll starts, this setting cannot be changed.

      > [!TIP] Choose the setting before inviting voters.
    MARKDOWN

    alerts = fragment.css("blockquote.markdown-alert")
    assert_equal 2, alerts.length
    assert_equal "Warning", alerts.first.at_css(".markdown-alert-title").text.strip
    assert_equal "Once a poll starts, this setting cannot be changed.", alerts.first.css("p").last.text.strip
    assert_equal Docs::MARKDOWN_ALERTS.dig("warning", :icon), alerts.first.at_css("svg path")["d"]
    assert_equal "Tip", alerts.last.at_css(".markdown-alert-title").text.strip
    assert_equal "Choose the setting before inviting voters.", alerts.last.css("p").last.text.strip
    refute_includes fragment.text, "[!WARNING]"
  end

  def test_leaves_ordinary_blockquotes_unchanged
    fragment = render_markdown("> This is a quotation.\n")

    assert_equal 1, fragment.css("blockquote").length
    assert_empty fragment.css("blockquote.markdown-alert")
    assert_equal "This is a quotation.", fragment.at_css("blockquote").text.strip
  end

  private

  def render_markdown(markdown)
    renderer = Docs::MarkdownRenderer.new
    rendered = Redcarpet::Markdown.new(renderer, Docs::MARKDOWN_OPTIONS).render(markdown)
    fragment = Nokogiri::HTML5.fragment(rendered)
    Docs::Builder.new.send(:render_alerts, fragment)
    fragment
  end
end
