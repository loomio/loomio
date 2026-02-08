# frozen_string_literal: true

class Views::Web::BootApp < Views::Web::Base
  include ApplicationHelper

  def initialize(metadata: nil, export: false, bot: false)
    @metadata = metadata
    @export = export
    @bot = bot
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
    link rel: "icon", href: AppConfig.theme[:icon_src]
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
          background-color: #f0f0f0;
          justify-content: center;
        }

        @media (prefers-color-scheme: dark) {
          #loading-placeholder {
            background-color: #1B1B1B;
          }
        }

        #loading-placeholder img, #loading-placeholder svg {
          max-width: 256px;
          height: auto;
        }
      CSS
    end
  end
end
