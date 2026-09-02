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

  def test_renders_local_png_screenshots_at_their_2x_intrinsic_density
    fragment = render_markdown("![Sidebar](sidebar.png)\n\n![External](https://example.com/diagram.png)\n\n![Animation](animation.gif)\n")

    screenshot = fragment.at_css('img[src="sidebar.png"]')
    assert_includes screenshot["class"].split, "screenshot-2x"
    assert_equal "sidebar.png 2x", screenshot["srcset"]
    assert_nil fragment.at_css('img[src="https://example.com/diagram.png"]')["srcset"]
    assert_nil fragment.at_css('img[src="animation.gif"]')["srcset"]
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
    builder = Docs::Builder.new
    builder.send(:render_alerts, fragment)
    builder.send(:mark_high_density_screenshots, fragment)
    fragment
  end
end
