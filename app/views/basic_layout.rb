# frozen_string_literal: true

class Views::BasicLayout < Views::Application::Component
  def initialize(flash: {})
    @flash = flash
  end

  def around_template(&)
    doctype
    html(lang: I18n.locale) do
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
      end
    end
  end

  private

  def render_head
    title { plain AppConfig.theme[:site_name] }
    meta charset: "utf-8"
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
