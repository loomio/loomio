# frozen_string_literal: true

class Views::Application::Layout < Views::Application::Component
  include ApplicationHelper

  def initialize(metadata: nil, export: false, bot: false)
    @metadata = metadata
    @export = export
    @bot = bot
  end

  def around_template(&)
    doctype
    html(lang: I18n.locale) do
      head { render_head }
      body do
        div(id: "app", data_v_app: true) do
          div(class: "v-theme--auto v-application v-layout v-layout--full-height v-locale--is-ltr") do
            div(class: "v-application__wrap") do
              render_navbar
              super(&)
              render_footer
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
    stylesheet_link_tag "vtfy/themeauto"
    raw vue_css_includes.html_safe
    unless @export || @bot
      raw vue_js_includes.html_safe
    end
  end

  def render_navbar
    header(class: "px-4 v-toolbar v-toolbar--density-default bg-background v-theme--dark v-locale--is-ltr v-app-bar lmo-no-print") do
      div(class: "v-toolbar__content d-flex justify-space-between", style: "height: 56px;") do
        div(class: "v-toolbar__title") { plain AppConfig.theme[:site_name] }
        div(class: "spacer")
        div(class: "v-toolbar__items")
        a(class: "navbar__sign-in v-btn v-btn--flat v-btn--text theme--auto v-size--default", href: "?sign_in=1") do
          plain t(:"navbar.sign_in")
        end
      end
    end
  end

  def render_footer
    footer(class: "v-footer theme--auto text-body-2") do
      div(class: "v-layout justify-space-around") do
        div(class: "powered-by caption") do
          a(href: "https://www.loomio.com?utm_source=#{ENV['CANONICAL_HOST']}&utm_campaign=appfooter", target: "_blank") do
            plain t(:"powered_by.powered_by_loomio")
          end
          span { plain " \u00b7 " }
          a(href: AppConfig.theme[:privacy_url], target: "_blank") { plain t(:"powered_by.privacy_policy") }
          span { plain " \u00b7 " }
          a(href: AppConfig.theme[:terms_url], target: "_blank") { plain t(:"powered_by.terms_of_service") }
          span { plain " \u00b7 " }
          a(href: AppConfig.theme[:help_url], target: "_blank") { plain t(:"common.help") }
        end
      end
    end
  end
end
