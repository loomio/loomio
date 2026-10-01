#!/usr/bin/env ruby
# frozen_string_literal: true

# Reports translated manual sections that use a rendering the glossary
# (config/locales/glossary.yml) marks as wrong for a term their English uses.
# Writes tmp/glossary/docs_<locale>.csv for review and prints a count per
# language. Informational: it never fails the build, because an English word
# is not always used in its Loomio sense.
# Usage: bundle exec ruby docs/check_glossary.rb [LOCALE...]

require "csv"
require "fileutils"
require_relative "localization"

module Docs
  class GlossaryCheck
    ROOT = Pathname(__dir__).freeze

    def initialize(root: ROOT, locales: Localization.locales.select(&:published))
      @root = root
      @locales = locales
    end

    # [[page, section id, problems]] for one locale.
    def problems(locale)
      pages.flat_map do |page|
        english = Localization.parse(Localization.annotate(@root.join("en", page).read)).by_id
        file = @root.join(locale.code, page)
        next [] unless file.file?

        Localization.parse(file.read).sections.filter_map do |section|
          source = english[section.id]
          next unless source

          found = TranslationGlossary.wrong_terms(source.text, section.text, locale.app_locale)
          [page, section.id, found] if found.any?
        end
      end
    end

    def report(output: @root.join("../tmp/glossary"))
      FileUtils.mkdir_p(output)
      @locales.to_h do |locale|
        rows = problems(locale)
        CSV.open(output.join("docs_#{locale.code}.csv"), "w") do |csv|
          csv << %w[page section problems]
          rows.each { |page, id, found| csv << [page, id, found.join("; ")] }
        end
        [locale.code, rows.size]
      end
    end

    private

    def pages
      @pages ||= @root.join("SUMMARY.md").read.scan(/\[[^\]]+\]\(([^)]+\.md)\)/).flatten.select { |path| Localization.translated?(path) }
    end
  end
end

if $PROGRAM_NAME == __FILE__
  codes = ARGV
  locales = Docs::Localization.locales.select(&:published)
  locales = locales.select { |locale| codes.include?(locale.code) } if codes.any?
  Docs::GlossaryCheck.new(locales: locales).report.each { |code, count| puts "#{code}: #{count} sections with wrong terms" }
end
