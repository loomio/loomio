#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "csv"
require "date"
require "fileutils"
require "nokogiri"
require "pathname"
require "redcarpet"
require "set"
require "uri"
require "yaml"

require_relative "template"

module Docs
  SOURCE_ROOT = Pathname(__dir__).expand_path.freeze
  OUTPUT_ROOT = Pathname(ENV.fetch("DOCS_OUTPUT", SOURCE_ROOT.join("../public/docs"))).expand_path.freeze
  BASE_PATH = ENV.fetch("DOCS_BASE_PATH", "/docs").sub(%r{/+\z}, "").freeze
  SITE_ORIGIN = ENV.fetch("DOCS_SITE_ORIGIN", BASE_PATH.empty? ? "https://help.loomio.com" : "https://www.loomio.com").freeze
  REDIRECT_TARGET = ENV["DOCS_REDIRECT_TARGET"]&.sub(%r{/+\z}, "")&.freeze
  SITE_PREFIX = "#{BASE_PATH}/en".freeze
  CHANGELOG_INDEX = "user_manual/changelog/index.md"
  CHANGELOG_PATTERN = /\A\d{4}-\d{2}-\d{2}_.+\.md\z/
  MARKDOWN_OPTIONS = {
    autolink: true,
    fenced_code_blocks: true,
    no_intra_emphasis: true,
    space_after_headers: true,
    strikethrough: true,
    superscript: true,
    tables: true,
    underline: true
  }.freeze

  Heading = Data.define(:level, :id, :title)

  class Page
    attr_accessor :description, :headings, :html, :title
    attr_reader :navigation_title, :source_path

    def initialize(navigation_title:, source_path:)
      @navigation_title = navigation_title
      @source_path = source_path
      @headings = []
    end

    def output_path
      published_path = source_path.sub(%r{/index\.md\z}, ".html").sub(/\.md\z/, ".html")
      Docs::OUTPUT_ROOT.join("en", published_path)
    end

    def url
      path = source_path.sub(%r{/index\.md\z}, "").sub(/\.md\z/, "")
      "#{Docs::SITE_PREFIX}/#{path}"
    end

    def canonical_url
      "#{Docs::SITE_ORIGIN}#{url}"
    end

    def index?
      source_path.end_with?("/index.md")
    end

    def legacy_index_path
      return unless index?

      Docs::OUTPUT_ROOT.join("en", source_path.sub(/\.md\z/, ".html"))
    end

  end

  class NavigationNode
    attr_reader :children, :page

    def initialize(page)
      @page = page
      @children = []
    end

    def contains?(candidate)
      page.equal?(candidate) || children.any? { |child| child.contains?(candidate) }
    end
  end

  Section = Data.define(:title, :nodes)

  def self.site_path(path)
    "#{BASE_PATH}#{path}"
  end

  class MarkdownRenderer < Redcarpet::Render::HTML
    def initialize
      super(with_toc_data: false)
      @heading_counts = Hash.new(0)
    end

    def header(text, level)
      title = Nokogiri::HTML5.fragment(text).text.strip
      slug = title.downcase
        .unicode_normalize(:nfkd)
        .gsub(/\p{Mn}/, "")
        .gsub(/[^\p{Alnum}_ -]/, "")
        .strip
        .gsub(/[ _]+/, "-")
      slug = "section" if slug.empty?

      count = @heading_counts[slug]
      @heading_counts[slug] += 1
      slug = "#{slug}-#{count}" if count.positive?

      %(<h#{level} id="#{CGI.escape_html(slug)}"><a class="heading-anchor" href="##{CGI.escape_html(slug)}">#{text}</a></h#{level}>)
    end
  end

  class Builder
    def run
      sections, pages = parse_summary
      raise "SUMMARY.md does not contain any pages" if pages.empty?

      FileUtils.rm_rf(OUTPUT_ROOT)
      FileUtils.mkdir_p(OUTPUT_ROOT)

      pages_by_source = pages.to_h { |page| [page.source_path, page] }
      pages_by_url = page_url_lookup(pages)

      if REDIRECT_TARGET
        build_cloudflare_redirects(pages, pages_by_url)
        return
      end

      pages.each { |page| render_markdown(page, pages_by_source, pages_by_url) }
      pages.each_with_index do |page, index|
        write_page(
          page,
          sections,
          previous_page: index.positive? ? pages[index - 1] : nil,
          next_page: pages[index + 1]
        )
      end

      copy_page_assets(pages)
      copy_static_assets
      write_site_assets
      if legacy_redirects?
        write_redirects(pages_by_url)
        write_page_aliases(pages)
      end
      write_landing_redirect
      write_sitemap(pages)
      validate_site(pages)

      puts "built #{pages.length} pages in #{OUTPUT_ROOT.relative_path_from(SOURCE_ROOT.parent)}"
    end

    private

    def legacy_redirects?
      BASE_PATH.empty?
    end

    def build_cloudflare_redirects(pages, pages_by_url)
      raise "DOCS_BASE_PATH must be empty when generating Cloudflare redirects" unless BASE_PATH.empty?

      exact_redirects = {}
      pages.each do |page|
        clean_path = page.url
        target_url = redirect_target_url(clean_path)
        page_source_variants(clean_path, page.index?).each { |path| exact_redirects[path] = target_url }
      end

      YAML.safe_load_file(SOURCE_ROOT.join("redirects.yml")).each do |from, target|
        target_page = pages_by_url[target]
        raise "redirect target does not name a published page: #{target}" if target.start_with?("/en/") && target_page.nil?

        target_url = target_page ? redirect_target_url(target_page.url) : target
        legacy_source_variants("/en#{from}").each { |path| exact_redirects[path] = target_url }
      end

      exact_path = OUTPUT_ROOT.join("cloudflare-help-exact.csv")
      prefix_path = OUTPUT_ROOT.join("cloudflare-help-prefixes.csv")
      write_cloudflare_csv(exact_path, exact_redirects.sort.map { |path, target| cloudflare_row(path, target) })
      write_cloudflare_csv(prefix_path, [
        cloudflare_row(
          "/en/user_manual/groups/integrations",
          "#{REDIRECT_TARGET}/en/user_manual/integrations",
          subpath_matching: true,
          preserve_path_suffix: true
        ),
        cloudflare_row("/", "#{REDIRECT_TARGET}/", subpath_matching: true, preserve_path_suffix: true)
      ])

      validate_cloudflare_csv(exact_path, prefix_path)
      puts "built #{exact_redirects.length} exact redirects and 2 prefix redirects in #{OUTPUT_ROOT.relative_path_from(SOURCE_ROOT.parent)}"
    end

    def redirect_target_url(path)
      "#{REDIRECT_TARGET}#{clean_internal_url(path)}"
    end

    def page_source_variants(clean_path, index_page)
      return [clean_path, "#{clean_path}.html"] unless index_page

      [clean_path, "#{clean_path}/", "#{clean_path}.html", "#{clean_path}/index.html"]
    end

    def legacy_source_variants(path)
      if path.end_with?("/index.html")
        clean_path = path.delete_suffix("/index.html")
        [path, clean_path, "#{clean_path}/"]
      elsif path.end_with?(".html")
        [path, path.delete_suffix(".html")]
      else
        [path]
      end
    end

    def cloudflare_row(source_path, target_url, subpath_matching: false, preserve_path_suffix: false)
      [
        "help.loomio.com#{source_path}",
        target_url,
        301,
        true,
        false,
        subpath_matching,
        preserve_path_suffix
      ]
    end

    def write_cloudflare_csv(path, rows)
      CSV.open(path, "w") { |csv| rows.each { |row| csv << row } }
    end

    def validate_cloudflare_csv(exact_path, prefix_path)
      exact_rows = CSV.read(exact_path)
      prefix_rows = CSV.read(prefix_path)
      failures = []

      failures << "exact redirect sources are not unique" unless exact_rows.map(&:first).uniq.length == exact_rows.length
      failures << "exact redirect list is empty" if exact_rows.empty?
      failures << "prefix redirect list must contain two entries" unless prefix_rows.length == 2

      (exact_rows + prefix_rows).each do |row|
        failures << "invalid Cloudflare redirect row: #{row.inspect}" unless row.length == 7
        failures << "redirect does not target the canonical docs host: #{row.inspect}" unless row[1]&.start_with?(REDIRECT_TARGET)
        failures << "redirect is not permanent: #{row.inspect}" unless row[2] == "301"
      end

      raise "Cloudflare redirect validation failed:\n- #{failures.join("\n- ")}" if failures.any?

      puts "validated #{exact_rows.length + prefix_rows.length} Cloudflare redirects"
    end

    def parse_summary
      sections = []
      pages = []
      current_section = nil
      node_stack = []

      SOURCE_ROOT.join("SUMMARY.md").each_line.with_index(1) do |line, line_number|
        if (heading = line.match(/^#\s+(.+?)\s*$/))
          current_section = Section.new(title: heading[1], nodes: [])
          sections << current_section
          node_stack.clear
          next
        end

        link = line.match(/^(\s*)-\s+\[([^\]]+)\]\(([^)]+\.md)\)\s*$/)
        next unless link
        raise "SUMMARY.md:#{line_number}: page appears before a section heading" unless current_section

        indentation = link[1].length
        raise "SUMMARY.md:#{line_number}: indentation must use pairs of spaces" unless (indentation % 2).zero?

        depth = indentation / 2
        page = Page.new(navigation_title: link[2], source_path: link[3])
        source_file = SOURCE_ROOT.join(page.source_path)
        raise "SUMMARY.md:#{line_number}: missing #{page.source_path}" unless source_file.file?
        raise "SUMMARY.md:#{line_number}: duplicate #{page.source_path}" if pages.any? { |item| item.source_path == page.source_path }

        node = NavigationNode.new(page)
        if depth.zero?
          current_section.nodes << node
        else
          parent = node_stack[depth - 1]
          raise "SUMMARY.md:#{line_number}: missing parent for #{page.source_path}" unless parent
          parent.children << node
        end

        node_stack[depth] = node
        node_stack.slice!((depth + 1)..)
        pages << page
      end

      [sections, pages]
    end

    def render_markdown(page, pages_by_source, pages_by_url)
      markdown = if page.source_path == CHANGELOG_INDEX
        changelog_markdown
      else
        SOURCE_ROOT.join(page.source_path).read
      end

      description_override = markdown[/<!--\s*seo-description:\s*(.*?)\s*-->/m, 1]
      renderer = MarkdownRenderer.new
      rendered = Redcarpet::Markdown.new(renderer, MARKDOWN_OPTIONS).render(markdown)
      fragment = Nokogiri::HTML5.fragment(rendered)

      fragment.xpath("//comment()").remove
      rewrite_links(fragment, page, pages_by_source, pages_by_url)
      wrap_tables(fragment)

      page.title = fragment.at_css("h1")&.text&.strip || page.navigation_title
      page.description = description_for(fragment, description_override, page.title)
      page.headings = fragment.css("h2, h3").map do |heading|
        Heading.new(level: heading.name.delete_prefix("h").to_i, id: heading["id"], title: heading.text.strip)
      end
      page.html = fragment.to_html
    end

    def changelog_markdown
      index = SOURCE_ROOT.join(CHANGELOG_INDEX).read.rstrip
      directory = SOURCE_ROOT.join(File.dirname(CHANGELOG_INDEX))
      entries = directory.children
        .select { |path| path.file? && path.basename.to_s.match?(CHANGELOG_PATTERN) }
        .sort_by { |path| path.basename.to_s }
        .reverse

      raise "No changelog entries found in #{directory}" if entries.empty?

      content = entries.map do |path|
        date_iso = path.basename.to_s[0, 10]
        date = Date.iso8601(date_iso).strftime("%-d %B %Y")
        markdown = path.read.strip.gsub(/^(#+)(?=\s)/) { |hashes| hashes.length < 6 ? "##{hashes}" : hashes }
        %(<p class="changelog-date"><time datetime="#{date_iso}">#{date}</time></p>\n\n#{markdown})
      end

      "#{index}\n\n#{content.join("\n\n")}\n"
    end

    def rewrite_links(fragment, page, pages_by_source, pages_by_url)
      fragment.css("a[href], img[src], iframe[src], video[src], source[src]").each do |element|
        attribute = element.name == "a" ? "href" : "src"
        value = element[attribute]
        next if value.nil? || value.empty?

        value = value.sub(%r{\Ahttps?://help\.loomio\.com(?=/|\z)}, "#{SITE_ORIGIN}#{BASE_PATH}")
        value = Docs.site_path(value) if value.start_with?("/en/", "/en#") || value == "/en"

        if element.name == "a"
          if (target = page_link(value, page, pages_by_source, pages_by_url))
            element[attribute] = target
            next
          end
        end

        value = absolute_source_url(value, page) if page.index? && relative_url?(value)
        value = clean_internal_url(value) if internal_url?(value)
        element[attribute] = value
      end
    end

    def page_url_lookup(pages)
      pages.each_with_object({}) do |page, lookup|
        source_markdown = "/en/#{page.source_path}"
        source_html = "/en/#{page.source_path.sub(/\.md\z/, ".html")}"
        clean_path = "/en/#{page.source_path.sub(%r{/index\.md\z}, "").sub(/\.md\z/, "")}"
        lookup[source_markdown] = page
        lookup[source_html] = page
        lookup[clean_path] = page
        lookup["#{clean_path}/"] = page if page.source_path.end_with?("/index.md")
      end
    end

    def page_link(value, page, pages_by_source, pages_by_url)
      path, suffix = split_url(value)

      if relative_url?(value) && path.end_with?(".md")
        source_path = Pathname(page.source_path).dirname.join(path).cleanpath.to_s
        target = pages_by_source[source_path]
        raise "#{page.source_path}: link points to unpublished Markdown page #{path}" unless target
        return "#{target.url}#{suffix}"
      end

      site_path = if path.start_with?("#{SITE_ORIGIN}#{BASE_PATH}/")
        path.delete_prefix("#{SITE_ORIGIN}#{BASE_PATH}")
      elsif !BASE_PATH.empty? && path.start_with?("#{BASE_PATH}/en/")
        path.delete_prefix(BASE_PATH)
      elsif path.start_with?("/en/")
        path
      end
      target = pages_by_url[site_path]
      "#{target.url}#{suffix}" if target
    end

    def absolute_source_url(value, page)
      path, suffix = split_url(value)
      source_path = Pathname(page.source_path).dirname.join(path).cleanpath
      "#{SITE_PREFIX}/#{source_path}#{suffix}"
    end

    def relative_url?(value)
      !value.start_with?("/", "#", "?") && !value.match?(%r{\A(?:[a-z][a-z0-9+.-]*:|//)}i)
    end

    def internal_url?(value)
      !value.match?(%r{\A(?:[a-z][a-z0-9+.-]*:|//)}i) || value.start_with?("#{SITE_ORIGIN}#{BASE_PATH}/")
    end

    def clean_internal_url(value)
      path, suffix = split_url(value)
      path = path.sub(%r{/index\.html\z}, "").sub(/\.html\z/, "")
      "#{path}#{suffix}"
    end

    def split_url(value)
      match = value.match(/\A([^?#]*)(.*)\z/m)
      [match[1], match[2]]
    end

    def wrap_tables(fragment)
      fragment.css("table").each do |table|
        wrapper = Nokogiri::XML::Node.new("div", fragment.document)
        wrapper["class"] = "table-wrapper"
        table.replace(wrapper)
        wrapper.add_child(table)
      end
    end

    def description_for(fragment, override, title)
      description = plain_text(override.to_s)
      if description.empty?
        description = fragment.css("p").map { |paragraph| plain_text(paragraph.text) }.find { |text| text.length >= 40 }.to_s
      end
      description = "#{title}. Help and guidance for using Loomio." if description.empty?
      truncate(description, 160)
    end

    def plain_text(value)
      Nokogiri::HTML5.fragment(value).text.gsub(/\s+/, " ").strip
    end

    def truncate(value, length)
      return value if value.length <= length

      shortened = value[0, length - 1]
      last_space = shortened.rindex(" ")
      shortened = shortened[0, last_space] if last_space && last_space > 110
      "#{shortened}…"
    end

    def write_page(page, sections, previous_page:, next_page:)
      FileUtils.mkdir_p(page.output_path.dirname)
      html = DocsTemplate.new(
        page: page,
        sections: sections,
        previous_page: previous_page,
        next_page: next_page
      ).call
      page.output_path.write("#{html}\n")
    end

    def copy_page_assets(pages)
      roots = pages.map { |page| page.source_path.split("/").first }.uniq
      roots.each do |root|
        source = SOURCE_ROOT.join(root)
        next unless source.directory?

        source.find do |path|
          next if path.directory? || path.extname == ".md"

          destination = OUTPUT_ROOT.join("en", path.relative_path_from(SOURCE_ROOT))
          FileUtils.mkdir_p(destination.dirname)
          FileUtils.cp(path, destination)
        end
      end
    end

    def copy_static_assets
      SOURCE_ROOT.join("static").children.each do |source|
        next if [".nojekyll", "CNAME", "index.html", "robots.txt"].include?(source.basename.to_s)

        destination = OUTPUT_ROOT.join(source.basename)
        if source.directory?
          FileUtils.mkdir_p(destination)
          source.children.each do |child|
            next if source.basename.to_s == "en" && child.basename.to_s == "legal" && !legacy_redirects?

            FileUtils.cp_r(child, destination.join(child.basename))
          end
        else
          FileUtils.cp(source, destination)
        end
      end

      OUTPUT_ROOT.glob("**/*.html").each do |path|
        html = path.read
          .gsub("https://help.loomio.com", "#{SITE_ORIGIN}#{BASE_PATH}")
          .gsub('href="/normalize.css"', %(href="#{Docs.site_path("/normalize.css")}"))
          .gsub('href="/styles.css"', %(href="#{Docs.site_path("/styles.css")}"))
          .gsub('src="/brand/', %(src="#{Docs.site_path("/brand/")}))
          .gsub('href="/en/', %(href="#{Docs.site_path("/en/")}))
          .gsub("url=/en/", "url=#{Docs.site_path("/en/")}")
          .gsub("/index.html", "")
        path.write(html)
      end
    end

    def write_site_assets
      FileUtils.cp(SOURCE_ROOT.join("docs.css"), OUTPUT_ROOT.join("docs.css"))
      FileUtils.cp(SOURCE_ROOT.join("docs.js"), OUTPUT_ROOT.join("docs.js"))
      OUTPUT_ROOT.join("robots.txt").write("Sitemap: #{SITE_ORIGIN}#{Docs.site_path("/sitemap.xml")}\n")
    end

    def write_redirects(pages_by_url)
      redirects = YAML.safe_load_file(SOURCE_ROOT.join("redirects.yml"))
      redirects.each do |from, target|
        source_path = OUTPUT_ROOT.join("en", from.delete_prefix("/"))
        target_url = pages_by_url[target]&.url || (target.start_with?("/en/") ? Docs.site_path(target) : target)
        write_redirect(source_path, target_url)
      end
    end

    def write_page_aliases(pages)
      pages.select(&:index?).each do |page|
        write_redirect(page.legacy_index_path, page.url)
      end
    end

    def write_landing_redirect
      target = Docs.site_path("/en/user_manual/overview")
      write_redirect(OUTPUT_ROOT.join("index.html"), target)
      write_redirect(OUTPUT_ROOT.join("en/index.html"), target)
    end

    def write_redirect(path, target)
      canonical_url = target.start_with?("/") ? "#{SITE_ORIGIN}#{target}" : target
      html = <<~HTML
        <!doctype html>
        <html lang="en">
          <head>
            <meta charset="utf-8">
            <meta http-equiv="refresh" content="0; url=#{CGI.escape_html(target)}">
            <link rel="canonical" href="#{CGI.escape_html(canonical_url)}">
            <title>Redirecting - Loomio Help</title>
          </head>
          <body><p><a href="#{CGI.escape_html(target)}">Continue to Loomio Help</a></p></body>
        </html>
      HTML
      FileUtils.mkdir_p(path.dirname)
      path.write(html)
    end

    def write_sitemap(pages)
      urls = pages.map(&:canonical_url).sort
      xml = [
        %(<?xml version="1.0" encoding="UTF-8"?>),
        %(<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">),
        *urls.map { |url| "  <url><loc>#{CGI.escape_html(url)}</loc></url>" },
        %(</urlset>),
        ""
      ].join("\n")
      OUTPUT_ROOT.join("sitemap.xml").write(xml)
    end

    def validate_site(pages)
      failures = []
      checked_links = 0

      OUTPUT_ROOT.glob("**/*.html").each do |source|
        document = Nokogiri::HTML5(source.read)
        document.css("a[href], img[src], iframe[src], video[src], source[src], link[href], script[src]").each do |element|
          attribute = element.key?("href") ? "href" : "src"
          value = element[attribute]
          target = internal_target(source, value)
          next unless target

          checked_links += 1
          resolved = resolve_file(target)
          failures << %(#{source.relative_path_from(OUTPUT_ROOT)}: #{attribute}="#{value}" does not resolve) unless resolved
        end

        document.css("meta[http-equiv]").select { |element| element["http-equiv"].casecmp?("refresh") }.each do |element|
          value = element["content"].to_s[/\burl=(.+)\z/i, 1]&.strip
          target = internal_target(source, value)
          next unless target

          checked_links += 1
          failures << %(#{source.relative_path_from(OUTPUT_ROOT)}: refresh target "#{value}" does not resolve) unless resolve_file(target)
        end
      end

      sitemap_urls = OUTPUT_ROOT.join("sitemap.xml").read.scan(%r{<loc>([^<]+)</loc>}).flatten.to_set
      expected_urls = pages.map(&:canonical_url).to_set
      failures << "sitemap contains duplicate URLs" unless sitemap_urls.length == pages.length
      failures << "sitemap does not match the rendered page set" unless sitemap_urls == expected_urls

      pages.each do |page|
        document = Nokogiri::HTML5(page.output_path.read)
        failures << "#{page.source_path}: missing title" unless document.at_css("title")&.text == "#{page.title} - Loomio Help"
        failures << "#{page.source_path}: missing description" if document.at_css('meta[name="description"]')&.[]("content").to_s.empty?
        failures << "#{page.source_path}: incorrect canonical URL" unless document.at_css('link[rel="canonical"]')&.[]("href") == page.canonical_url
      end

      raise "Documentation validation failed:\n- #{failures.join("\n- ")}" if failures.any?

      puts "validated #{checked_links} internal links and assets"
    end

    def internal_target(source, value)
      return nil if value.nil? || value.empty? || value.start_with?("#", "mailto:", "tel:", "data:", "javascript:", "//")

      path = value.split(/[?#]/, 2).first
      origin_prefix = "#{SITE_ORIGIN}#{BASE_PATH}"
      path = path.delete_prefix(SITE_ORIGIN) if path.start_with?(origin_prefix)
      return nil if path.match?(%r{\Ahttps?://})

      if path.start_with?("/")
        return nil unless BASE_PATH.empty? || path == BASE_PATH || path.start_with?("#{BASE_PATH}/")

        relative = BASE_PATH.empty? ? path.delete_prefix("/") : path.delete_prefix(BASE_PATH).delete_prefix("/")
        OUTPUT_ROOT.join(CGI.unescape(relative))
      else
        source.dirname.join(CGI.unescape(path)).cleanpath
      end
    end

    def resolve_file(path)
      return path if path.file?
      html_path = Pathname("#{path}.html")
      return html_path if html_path.file?

      path.join("index.html") if path.join("index.html").file?
    end
  end
end

Docs::Builder.new.run if $PROGRAM_NAME == __FILE__
