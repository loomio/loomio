# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require "tmpdir"
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

  def test_every_published_language_explains_machine_translation_with_the_feedback_email
    Docs::Localization.locales.select(&:published).each do |locale|
      notice = Docs::Localization.site_strings(locale.code).fetch("machine_translation_notice")
      assert_includes notice, "%{email}", locale.code
    end
  end

  def test_leaves_ordinary_blockquotes_unchanged
    fragment = render_markdown("> This is a quotation.\n")

    assert_equal 1, fragment.css("blockquote").length
    assert_empty fragment.css("blockquote.markdown-alert")
    assert_equal "This is a quotation.", fragment.at_css("blockquote").text.strip
  end

  def test_legacy_index_redirects_cover_clean_and_index_urls
    paths = Docs::Builder.new.send(
      :redirect_output_paths,
      "/user_manual/polls/starting_proposals/index.html"
    )

    assert_equal [
      Docs::OUTPUT_ROOT.join("en/user_manual/polls/starting_proposals/index.html"),
      Docs::OUTPUT_ROOT.join("en/user_manual/polls/starting_proposals.html")
    ], paths
  end

  def test_localized_assets_override_shared_english_assets
    Dir.mktmpdir("docs-assets") do |directory|
      page = Docs::Page.new(navigation_title: "Exemple", source_path: "user_manual/example/index.md", locale: "fr")
      builder = Docs::Builder.new
      Docs::Localization.stub(:path, ->(locale, source) { Pathname(directory).join(locale, source) }) do
        assert_equal "#{Docs::BASE_PATH}/en/user_manual/example/image.png#detail", builder.send(:absolute_source_url, "image.png#detail", page)
        asset = Pathname(directory).join("fr/user_manual/example/image.png")
        FileUtils.mkdir_p(asset.dirname)
        asset.write("localized image")
        assert_equal "#{Docs::BASE_PATH}/fr/user_manual/example/image.png#detail", builder.send(:absolute_source_url, "image.png#detail", page)
      end
    end
  end

  def test_section_and_correction_comments_are_removed_from_rendered_pages
    page = Docs::Page.new(navigation_title: "Example", source_path: "user_manual/example.md")
    markdown = "<!-- translation-section: introduction -->\n\n# Example\n\n<!-- translation-correction: {\"before\":\"old\",\"after\":\"new\"} -->\n\nA paragraph.\n"
    Docs::Builder.new.send(:render_markdown, page, {}, {}, markdown: markdown)
    refute_includes page.html, "translation-section"
    refute_includes page.html, "translation-correction"
    assert_includes page.html, "A paragraph."
  end

  def test_translated_screenshots_keep_english_html_and_supply_runtime_fallbacks
    fragment = render_markdown("![Save](#{Docs::BASE_PATH}/en/user_manual/users/bookmarks/save_bookmark.png)\n\n![Diagram](#{Docs::BASE_PATH}/en/guides/facilitators_guide/collaboration-process.png)\n")
    page = Docs::Page.new(navigation_title: "Signets", source_path: "user_manual/users/bookmarks/index.md", locale: "fr")
    Docs::Builder.new.send(:mark_localized_screenshots, fragment, page)
    image = fragment.css("img").first
    assert_equal "#{Docs::BASE_PATH}/en/user_manual/users/bookmarks/save_bookmark.png", image["src"]
    assert_equal "#{image['src']} 2x", image["srcset"]
    assert_equal [
      "/docs-screenshots/fr/user_manual/users/bookmarks/save_bookmark.png",
      "https://user-manual-screenshots.loomio.com/fr/user_manual/users/bookmarks/save_bookmark.png",
      image["src"]
    ], JSON.parse(image["data-screenshot-sources"])
    assert_nil fragment.css("img").last["data-screenshot-sources"]
  end

  def test_supplied_locale_asset_precedes_generated_cache_and_hosted_copy
    fragment = render_markdown("![Save](#{Docs::BASE_PATH}/fr/user_manual/users/bookmarks/save_bookmark.png)")
    page = Docs::Page.new(navigation_title: "Signets", source_path: "user_manual/users/bookmarks/index.md", locale: "fr")
    Docs::Builder.new.send(:mark_localized_screenshots, fragment, page)
    image = fragment.at_css("img")
    assert_equal image["src"], JSON.parse(image["data-screenshot-sources"]).first
  end

  private

  def render_markdown(markdown)
    renderer = Docs::MarkdownRenderer.new
    rendered = Redcarpet::Markdown.new(renderer, Docs::MARKDOWN_OPTIONS).render(markdown)
    fragment = Nokogiri::HTML5.fragment(rendered)
    builder = Docs::Builder.new
    builder.send(:render_alerts, fragment, "en")
    builder.send(:mark_high_density_screenshots, fragment)
    fragment
  end
end
