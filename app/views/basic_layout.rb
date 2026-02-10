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
            img(style: "max-width: 192px", src: AppConfig.theme[:app_logo_src])
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
    link rel: "shortcut icon", href: AppConfig.theme[:icon_src]
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
