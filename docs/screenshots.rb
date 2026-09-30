# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "open3"
require "pathname"
require "tempfile"
require "time"
require "tmpdir"
require "yaml"

module Docs
  # The cache has one PNG per language/path and one manifest, never historical
  # copies. Fingerprints describe capture inputs; they do not change filenames.
  module Screenshots
    ROOT = Pathname(__dir__).parent.freeze
    URL_ROOT = "/docs-screenshots"
    HOSTED_ROOT = "https://user-manual-screenshots.loomio.com"
    SHARED_INPUTS = %w[
      vue/tests/e2e/helpers/manualScreenshot.js
      vue/tests/e2e/helpers/pageHelper.js
      vue/tests/e2e/helpers/oatmilkRichText.js
      vue/nightwatch.conf.js bin/e2e-screenshots
      app/controllers/dev/base_controller.rb
      app/controllers/dev/scenarios/oatmilk_cooperative.rb
      bin/compress-screenshot bin/crop-screenshot bin/spotlight-screenshot
    ].freeze

    def self.catalog
      @catalog ||= begin
        output, status = Open3.capture2("node", ROOT.join("docs/screenshot_catalog.js").to_s)
        raise "Cannot discover screenshot recipes" unless status.success?
        JSON.parse(output)
      end
    end

    def self.images
      @images ||= catalog.to_h { |recipe| [recipe.fetch("image"), recipe] }
    end

    def self.fingerprint(recipe, app_locale)
      paths = ["docs/en/#{recipe.fetch('image')}", "vue/tests/e2e/screenshots/#{recipe.fetch('spec')}",
        "config/locales/client.en.yml", "config/locales/server.en.yml",
        "config/locales/client.#{app_locale}.yml", "config/locales/server.#{app_locale}.yml", *SHARED_INPUTS].uniq
      digest = Digest::SHA256.new
      digest.update("#{app_locale}\0#{recipe.fetch('testcase')}\0scale=2\0")
      @file_hashes ||= {}
      paths.each do |path|
        @file_hashes[path] ||= Digest::SHA256.file(ROOT.join(path)).hexdigest
        digest.update("#{path}\0#{@file_hashes.fetch(path)}\0")
      end
      digest.hexdigest[0, 16]
    end

    def self.labels(app_locale)
      # Specs mix fixed fictional content with interface text. Keep the fixed
      # content and accept locale equivalents for literal interface assertions.
      flatten = lambda do |values, prefix = "", result = {}|
        values.each do |key, value|
          name = "#{prefix}#{key}"
          value.is_a?(Hash) ? flatten.call(value, "#{name}.", result) : result[name] = value
        end
        result
      end
      result = Hash.new { |hash, key| hash[key] = [] }
      %w[client server].each do |kind|
        english = flatten.call(YAML.safe_load_file(ROOT.join("config/locales/#{kind}.en.yml")).fetch("en"))
        translated = flatten.call(YAML.safe_load_file(ROOT.join("config/locales/#{kind}.#{app_locale}.yml")).fetch(app_locale))
        english.each do |key, value|
          target = translated[key]
          next unless value.is_a?(String) && target.is_a?(String) && !value.include?("%{")
          result[value] << target unless result[value].include?(target)
        end
      end
      result
    end

    class Cache
      def initialize(directory)
        @directory = Pathname(directory).expand_path
        @manifest_path = @directory.join(".generation.json")
        @manifest = @manifest_path.file? ? JSON.parse(@manifest_path.read) : {}
      end

      def status(locale, recipe, inputs)
        key = "#{locale}/#{recipe.fetch('image')}"
        return "missing" unless @directory.join(key).file?
        @manifest.dig(key, "inputs") == inputs ? "current" : "outdated"
      end

      def store(locale, recipe, inputs, source)
        key = "#{locale}/#{recipe.fetch('image')}"
        destination = @directory.join(key)
        raise "Capture missing: #{source}" unless Pathname(source).file?
        atomic_write(destination, File.binread(source))
        @manifest[key] = {"inputs" => inputs, "generated_at" => Time.now.utc.iso8601}
        atomic_write(@manifest_path, JSON.pretty_generate(@manifest.sort.to_h) + "\n")
      end

      private

      def atomic_write(destination, bytes)
        FileUtils.mkdir_p(destination.dirname)
        Tempfile.create([".capture-", destination.extname], destination.dirname) do |file|
          file.binmode
          file.write(bytes)
          file.flush
          file.chmod(0o644)
          File.rename(file.path, destination)
        end
      end
    end
  end
end
