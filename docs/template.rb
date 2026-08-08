# frozen_string_literal: true

require "phlex"

class DocsTemplate < Phlex::HTML
  def initialize(page:, sections:, previous_page:, next_page:)
    @page = page
    @sections = sections
    @previous_page = previous_page
    @next_page = next_page
  end

  def view_template
    doctype
    html(lang: "en") do
      head { render_head }
      body do
        button(
          class: "sidebar-toggle",
          type: "button",
          aria_controls: "site-navigation",
          aria_expanded: "false",
          aria_label: "Open navigation"
        ) { plain "Menu" }

        div(class: "sidebar-scrim", aria_hidden: "true")
        aside(id: "site-navigation", class: "sidebar") { render_sidebar }

        div(class: "page") do
          div(class: "content-grid") do
            main { raw safe(@page.html) }
            render_page_toc
            render_page_navigation
          end
        end

        script(src: Docs.site_path("/docs.js"), defer: true)
        script(
          src: "https://measure.loomio.com/js/script.outbound-links.js",
          defer: true,
          data_domain: "www.loomio.com,all.loomio.com"
        )
      end
    end
  end

  private

  def render_head
    social_image_url = "#{Docs::SITE_ORIGIN}#{Docs.site_path("/brand/social-preview.png")}"

    title { plain "#{@page.title} - Loomio Help" }
    meta(charset: "utf-8")
    meta(name: "viewport", content: "width=device-width, initial-scale=1")
    meta(name: "description", content: @page.description)
    meta(name: "theme-color", content: "#ffffff", media: "(prefers-color-scheme: light)")
    meta(name: "theme-color", content: "#111111", media: "(prefers-color-scheme: dark)")
    meta(property: "og:title", content: "#{@page.title} - Loomio Help")
    meta(property: "og:description", content: @page.description)
    meta(property: "og:type", content: "website")
    meta(property: "og:url", content: @page.canonical_url)
    meta(property: "og:site_name", content: "Loomio Help")
    meta(property: "og:image", content: social_image_url)
    meta(property: "og:image:type", content: "image/png")
    meta(property: "og:image:width", content: "1200")
    meta(property: "og:image:height", content: "630")
    meta(property: "og:image:alt", content: "Loomio help and documentation")
    meta(name: "twitter:card", content: "summary_large_image")
    meta(name: "twitter:title", content: "#{@page.title} - Loomio Help")
    meta(name: "twitter:description", content: @page.description)
    meta(name: "twitter:image", content: social_image_url)
    meta(name: "twitter:image:alt", content: "Loomio help and documentation")
    link(rel: "canonical", href: @page.canonical_url)
    link(rel: "icon", type: "image/svg+xml", href: Docs.site_path("/brand/favicon-yellow-on-transparent.svg"))
    link(rel: "preconnect", href: "https://fonts.googleapis.com")
    link(rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: true)
    link(
      rel: "stylesheet",
      href: "https://fonts.googleapis.com/css2?family=Roboto+Mono&family=Roboto:wght@300;400;500;700&display=swap"
    )
    link(rel: "stylesheet", href: Docs.site_path("/docs.css"))
  end

  def render_sidebar
    a(class: "sidebar-logo", href: Docs.site_path("/en/user_manual/overview/index.html")) do
      img(src: Docs.site_path("/brand/logo-yellow.svg"), alt: "Loomio")
    end

    nav(aria_label: "Help contents") do
      @sections.each do |section|
        h2 { plain section.title } unless section.title == "Help"
        ul(class: "chapter-list") do
          section.nodes.each { |node| render_navigation_node(node) }
        end
      end
    end
  end

  def render_navigation_node(node)
    li do
      if node.children.empty?
        render_navigation_link(node.page)
      else
        details(open: node.contains?(@page)) do
          summary { render_navigation_link(node.page) }
          ul { node.children.each { |child| render_navigation_node(child) } }
        end
      end
    end
  end

  def render_navigation_link(page)
    a(
      href: page.url,
      class: page.equal?(@page) ? "current" : nil,
      aria_current: page.equal?(@page) ? "page" : nil
    ) { plain page.navigation_title }
  end

  def render_page_toc
    headings = @page.headings.reject { |heading| heading.title.match?(/\A(?:Examples?|Params)\z/i) }
    return if headings.empty?

    aside(class: "page-toc", aria_label: "On this page") do
      h2 { plain "On this page" }
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

    nav(class: "page-navigation", aria_label: "Page navigation") do
      if @previous_page
        a(href: @previous_page.url, rel: "prev") do
          small { plain "Previous" }
          span { plain @previous_page.navigation_title }
        end
      else
        span
      end

      if @next_page
        a(href: @next_page.url, rel: "next") do
          small { plain "Next" }
          span { plain @next_page.navigation_title }
        end
      end
    end
  end
end
