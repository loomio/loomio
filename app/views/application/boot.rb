# frozen_string_literal: true

class Views::Application::Boot < Views::Application::Component
  def initialize(metadata: nil, export: false, bot: false, theme_name: nil)
    @metadata = metadata
    @export = export
    @bot = bot
    @theme_name = theme_name
  end

  def view_template
    doctype
    html(lang: I18n.locale) do
      head { render_head }
      body do
        div(id: "app") do
          div(id: "loading-placeholder") do
            svg = logo_svg
            if svg
              raw svg
            else
              img(src: AppConfig.theme[:app_logo_src])
            end
          end
        end
      end
    end
  end

  private

  def meta_hash
    @metadata || {
      title: AppConfig.theme[:site_name],
      description: AppConfig.theme[:description],
      image_urls: []
    }
  end

  def render_head
    colors = loading_colors

    title { plain meta_hash[:title] }
    meta charset: "utf-8"
    meta name: "viewport", content: "width=device-width, initial-scale=1.0"
    meta content: meta_hash[:title], property: "og:title"
    meta content: meta_hash[:description], name: "description", property: "og:description"
    Array(meta_hash[:image_urls]).each do |image_url|
      meta content: image_url, property: "og:image"
    end
    meta content: AppConfig.theme[:site_name], property: "og:site_name"
    meta content: "website", property: "og:type"
    link rel: "icon", type: "image/png", sizes: "16x16", href: AppConfig.theme[:favicon16_src]
    link rel: "icon", type: "image/png", sizes: "32x32", href: AppConfig.theme[:favicon32_src]
    link rel: "icon", href: AppConfig.theme[:icon_src]
    link rel: "apple-touch-icon", href: AppConfig.theme[:touch_icon_src]
    raw vue_css_includes.html_safe
    unless @export || @bot
      raw vue_js_includes.html_safe
    end
    style do
      raw <<~CSS.html_safe
        html, body {
          height: 100%;
          margin: 0;
          padding: 0;
        }

        #loading-placeholder {
          position: fixed;
          padding: 0;
          margin: 0;
          display: flex;
          flex-direction: column;
          align-items: center;
          width: 100%;
          height: 100%;
          background-color: #{colors[:background]};
          color: #{colors[:foreground]};
          justify-content: center;
        }

        #loading-placeholder img, #loading-placeholder svg {
          display: block;
          width: 60%;
          max-width: 320px;
          height: auto;
        }

        #{loading_system_dark_css}
      CSS
    end
  end

  def loading_colors
    background = if loading_scheme == :dark
      AppConfig.theme[:brand_colors][:grey800]
    else
      AppConfig.theme[:brand_colors][:white]
    end

    {
      background:,
      foreground: AppConfig.theme[:accent_color]
    }
  end

  def loading_scheme
    return :dark if %w[dark darkBlue].include?(@theme_name)
    return :light if %w[light lightBlue].include?(@theme_name)

    :system
  end

  def loading_system_dark_css
    return if loading_scheme != :system

    <<~CSS
      @media (prefers-color-scheme: dark) {
        #loading-placeholder {
          background-color: #{AppConfig.theme[:brand_colors][:grey800]};
          color: #{AppConfig.theme[:accent_color]};
        }
      }
    CSS
  end
end
