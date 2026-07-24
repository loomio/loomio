# frozen_string_literal: true

class Views::BasicLayout < Views::Application::Component
  def initialize(flash: {}, title: nil, description: nil, canonical_url: nil, lang: I18n.locale, robots: nil, footer_branding: true)
    @flash = flash
    @title = title || AppConfig.theme[:site_name]
    @description = description
    @canonical_url = canonical_url
    @lang = lang
    @robots = robots
    @footer_branding = footer_branding
  end

  def around_template(&)
    doctype
    html(lang: @lang) do
      head { render_head }
      body do
        header do
          a(href: "/") do
            svg = logo_svg(style: "display: block; width: 100%; height: auto")
            if svg
              div(style: "color: #{AppConfig.theme[:accent_color]}; max-width: 192px") { raw svg }
            else
              img(style: "max-width: 192px", src: AppConfig.theme[:app_logo_src])
            end
          end
        end
        if @flash[:notice]
          div(class: "sistema") do
            aside(class: "flash-notice", role: "alert") { plain @flash[:notice] }
          end
        end
        super(&)
        render Views::Application::Footer.new(branding: @footer_branding)
      end
    end
  end

  private

  def render_head
    title { plain @title }
    meta charset: "utf-8"
    meta name: "viewport", content: "width=device-width, initial-scale=1.0"
    meta name: "description", content: @description if @description
    meta name: "robots", content: @robots if @robots
    link rel: "canonical", href: @canonical_url if @canonical_url
    if @description
      meta property: "og:title", content: @title
      meta property: "og:description", content: @description
      meta property: "og:type", content: "website"
      meta property: "og:url", content: @canonical_url if @canonical_url
      meta name: "twitter:card", content: "summary"
    end
    link rel: "stylesheet", href: "/roboto.css"
    link rel: "icon", type: "image/png", sizes: "16x16", href: AppConfig.theme[:favicon16_src]
    link rel: "icon", type: "image/png", sizes: "32x32", href: AppConfig.theme[:favicon32_src]
    link rel: "icon", href: AppConfig.theme[:icon_src]
    link rel: "apple-touch-icon", href: AppConfig.theme[:touch_icon_src]
    stylesheet_link_tag "basic"
    stylesheet_link_tag "loomiosubs"
    render_plausible
  end

  def render_plausible
    if ENV["PLAUSIBLE_SRC"] && ENV["PLAUSIBLE_SITE"]
      script(defer: true, data_domain: ENV["PLAUSIBLE_SITE"], src: ENV["PLAUSIBLE_SRC"])
    end
  end
end
