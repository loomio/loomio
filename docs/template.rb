# frozen_string_literal: true

require "phlex"
require_relative "localization"

class DocsTemplate < Phlex::HTML
  # English interface text. Each translated language overrides these in
  # docs/<locale>/_site.yml, which must define every key.
  STRINGS = {
    "site_title" => "Loomio Help",
    "menu" => "Menu",
    "open_navigation" => "Open navigation",
    "close_navigation" => "Close navigation",
    "search" => "Search",
    "search_label" => "Search Loomio Help",
    "help_contents" => "Help contents",
    "on_this_page" => "On this page",
    "page_navigation" => "Page navigation",
    "previous" => "Previous",
    "next" => "Next",
    "image_alt" => "Loomio help and documentation",
    "languages" => "Languages",
    "copy" => "Copy",
    "copy_label" => "Copy code to clipboard",
    "copied" => "Copied",
    "copy_failed" => "Copy failed",
    "alerts" => {"note" => "Note", "tip" => "Tip", "important" => "Important", "warning" => "Warning", "caution" => "Caution"},
    "sections" => {}
  }.freeze


  def initialize(page:, sections:, previous_page:, next_page:, localize:, alternates:, strings:)
    @page = page
    @sections = sections
    @previous_page = previous_page
    @next_page = next_page
    @localize = localize
    @alternates = alternates
    @strings = strings
  end

  def view_template
    doctype
    locale = Docs::Localization.locale(@page.locale)
    html(lang: locale.hreflang, dir: locale.dir == "rtl" ? "rtl" : nil, **script_strings) do
      head { render_head }
      body do
        button(
          class: "sidebar-toggle",
          type: "button",
          aria_controls: "site-navigation",
          aria_expanded: "false",
          aria_label: @strings["open_navigation"]
        ) { plain @strings["menu"] }

        div(class: "sidebar-scrim", aria_hidden: "true")
        aside(id: "site-navigation", class: "sidebar") { render_sidebar }
        tag(:"pagefind-modal", class: "pagefind-search-modal", reset_on_close: true)

        div(class: "page") do
          div(class: "content-grid") do
            main(**pagefind_attributes) { raw safe(@page.html) }
            render_page_toc
            render_page_navigation
          end
        end

        script(src: Docs.site_path("/docs.js"), defer: true)
        render_plausible
      end
    end
  end

  private

  def t(key)
    @strings.fetch(key)
  end

  # docs.js reads its interface text from the root element on translated pages
  # and uses its English defaults otherwise.
  def script_strings
    return {} if @page.locale == "en"

    %w[open_navigation close_navigation copy copy_label copied copy_failed].to_h { |key| [:"data_#{key}", t(key)] }
  end

  def pagefind_attributes
    @page.search_indexed? ? {data_pagefind_body: true} : {}
  end

  def render_plausible
    return unless ENV["PLAUSIBLE_SRC"] && ENV["PLAUSIBLE_SITE"]

    script(
      src: ENV["PLAUSIBLE_SRC"],
      defer: true,
      data_domain: ENV["PLAUSIBLE_SITE"]
    )
  end

  def render_head
    social_image_url = "#{Docs::SITE_ORIGIN}#{Docs.site_path("/brand/social-preview.png")}"

    title { plain "#{@page.title} - #{t("site_title")}" }
    meta(charset: "utf-8")
    meta(name: "viewport", content: "width=device-width, initial-scale=1")
    meta(name: "description", content: @page.description)
    meta(data_pagefind_meta: "title", content: @page.title)
    meta(name: "theme-color", content: "#ffffff", media: "(prefers-color-scheme: light)")
    meta(name: "theme-color", content: "#111111", media: "(prefers-color-scheme: dark)")
    meta(property: "og:title", content: "#{@page.title} - #{t("site_title")}")
    meta(property: "og:description", content: @page.description)
    meta(property: "og:type", content: "website")
    meta(property: "og:url", content: @page.canonical_url)
    meta(property: "og:site_name", content: t("site_title"))
    meta(property: "og:image", content: social_image_url)
    meta(property: "og:image:type", content: "image/png")
    meta(property: "og:image:width", content: "1200")
    meta(property: "og:image:height", content: "630")
    meta(property: "og:image:alt", content: t("image_alt"))
    meta(name: "twitter:card", content: "summary_large_image")
    meta(name: "twitter:title", content: "#{@page.title} - #{t("site_title")}")
    meta(name: "twitter:description", content: @page.description)
    meta(name: "twitter:image", content: social_image_url)
    meta(name: "twitter:image:alt", content: t("image_alt"))
    link(rel: "canonical", href: @page.canonical_url)
    @alternates.each do |code, page|
      link(rel: "alternate", hreflang: Docs::Localization.locale(code).hreflang, href: page.canonical_url)
    end
    link(rel: "alternate", hreflang: "x-default", href: @alternates.first.last.canonical_url) if @alternates.any?
    link(rel: "icon", type: "image/svg+xml", href: Docs.site_path("/brand/favicon-yellow-on-transparent.svg"))
    link(rel: "stylesheet", href: "/roboto.css")
    link(rel: "stylesheet", href: Docs.site_path("/pagefind/pagefind-component-ui.css"))
    link(rel: "stylesheet", href: Docs.site_path("/docs.css"))
    script(src: Docs.site_path("/pagefind/pagefind-component-ui.js"), type: "module")
  end

  def render_sidebar
    home_href = @page.locale == "en" ? Docs.site_path("/en/user_manual/overview/index.html") : home_page_url
    a(class: "sidebar-logo", href: home_href) do
      img(src: Docs.site_path("/brand/logo-yellow.svg"), alt: "Loomio")
    end

    div(class: "sidebar-search", role: "search", aria_label: t("search_label")) do
      tag(
        :"pagefind-config",
        bundle_path: Docs.site_path("/pagefind/"),
        base_url: Docs.site_path("/")
      )
      tag(
        :"pagefind-modal-trigger",
        placeholder: t("search"),
      )
    end

    nav(aria_label: t("help_contents")) do
      @sections.each do |section|
        h2 { plain t("sections").fetch(section.title, section.title) } unless section.title == "Help"
        ul(class: "chapter-list") do
          section.nodes.each { |node| render_navigation_node(node) }
        end
      end
    end

    render_language_select
  end

  def render_navigation_node(node)
    li do
      if node.children.empty?
        render_navigation_link(node.page)
      else
        details(open: node.contains?(@page.english)) do
          summary { render_navigation_link(node.page) }
          ul { node.children.each { |child| render_navigation_node(child) } }
        end
      end
    end
  end

  def render_navigation_link(page)
    page = @localize.call(page)
    a(
      href: page.url,
      class: page.equal?(@page) ? "current" : nil,
      aria_current: page.equal?(@page) ? "page" : nil,
      lang: page.locale == @page.locale ? nil : Docs::Localization.locale(page.locale).hreflang
    ) { plain page.navigation_title }
  end

  def render_page_toc
    headings = @page.headings.reject { |heading| heading.title.match?(/\A(?:Examples?|Params)\z/i) }
    return if headings.empty?

    aside(class: "page-toc", aria_label: t("on_this_page")) do
      h2 { plain t("on_this_page") }
      ul do
        headings.each do |heading|
          li(class: "toc-level-#{heading.level}") do
            a(href: "##{heading.id}") { plain heading.title }
          end
        end
      end
    end
  end

  def render_page_navigation
    return unless @previous_page || @next_page

    nav(class: "page-navigation", aria_label: t("page_navigation")) do
      if @previous_page
        a(href: @previous_page.url, rel: "prev") do
          small { plain t("previous") }
          span { plain @previous_page.navigation_title }
        end
      else
        span
      end

      if @next_page
        a(href: @next_page.url, rel: "next") do
          small { plain t("next") }
          span { plain @next_page.navigation_title }
        end
      end
    end
  end
  def home_page_url
    @localize.call(@sections.flat_map(&:nodes).first.page).url
  end

  # Readers normally arrive from the app in their own language, so switching
  # is kept to a compact select below the navigation. docs.js navigates on
  # change.
  def render_language_select
    return if @alternates.empty?

    div(class: "language-select") do
      label(for: "language-select") { plain t("languages") }
      # autocomplete off stops the browser restoring a previous choice when
      # the reader returns with the back button.
      select(id: "language-select", autocomplete: "off", data_language_select: true) do
        @alternates.each do |code, page|
          locale = Docs::Localization.locale(code)
          option(value: page.url, lang: locale.hreflang, selected: page.equal?(@page)) { plain locale.name }
        end
      end
    end
  end
end
