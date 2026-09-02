require "test_helper"

class ApplicationPwaHeadsTest < ActiveSupport::TestCase
  class TestLayout < Views::Application::Layout
    def view_template
      main { plain "Application content" }
    end
  end

  test "server application heads include PWA metadata" do
    components = [
      Views::Application::Boot.new(export: true),
      TestLayout.new(export: true)
    ]

    components.each do |component|
      document = Nokogiri::HTML(ApplicationController.renderer.render(component, layout: false))

      assert_pwa_head(
        document,
        theme_color: AppConfig.theme[:primary_color],
        title: AppConfig.theme[:site_short_name]
      )
    end
  end

  test "Vite development head includes PWA metadata" do
    document = Nokogiri::HTML(Rails.root.join("vue/index.html").read)

    assert_pwa_head(document, theme_color: "#0070E0", title: "Loomio")
  end

  private

  def assert_pwa_head(document, theme_color:, title:)
    head = document.at_css("head")

    assert head.at_css("link[rel='manifest'][href='/manifest']")
    assert_equal theme_color, head.at_css("meta[name='theme-color']")["content"]
    assert_equal "yes", head.at_css("meta[name='apple-mobile-web-app-capable']")["content"]
    assert_equal "default", head.at_css("meta[name='apple-mobile-web-app-status-bar-style']")["content"]
    assert_equal title, head.at_css("meta[name='apple-mobile-web-app-title']")["content"]
  end
end
