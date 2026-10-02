# frozen_string_literal: true

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
  # copies. Regeneration is selected explicitly; filenames stay stable.
  module Screenshots
    ROOT = Pathname(__dir__).parent.freeze
    URL_ROOT = "/docs-screenshots"
    HOSTED_ROOT = "https://user-manual-screenshots.loomio.com"
    BUCKET = "user-manual-screenshots"

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

    # Publish existing local captures, then their generation metadata. A failed
    # image upload must leave the previous hosted manifest in place. The cf
    # development mode loads credentials from the project's ignored local env.
    def self.publish(locale, recipes, directory)
      directory = Pathname(directory)
      recipes.each do |recipe|
        key = "#{locale}/#{recipe.fetch('image')}"
        return false unless system("cf", "r2", "objects", "put", key,
          "--bucket-name", BUCKET, "--file", directory.join(key).to_s,
          "--content-type", "image/png", "--quiet", "--mode", "development", chdir: ROOT.to_s)
      end

      manifest = JSON.parse(directory.join(".generation.json").read)
      entries = manifest.select { |key, _| key.start_with?("#{locale}/") }
      entries.transform_values! { |entry| entry.slice("generated_at") }
      Tempfile.create(["screenshot-manifest-", ".json"]) do |file|
        file.write(JSON.pretty_generate(entries) + "\n")
        file.flush
        system("cf", "r2", "objects", "put", "#{locale}/.generation.json",
          "--bucket-name", BUCKET, "--file", file.path,
          "--content-type", "application/json", "--quiet", "--mode", "development", chdir: ROOT.to_s)
      end
    end

    class Cache
      def initialize(directory)
        @directory = Pathname(directory).expand_path
        @manifest_path = @directory.join(".generation.json")
        @manifest = @manifest_path.file? ? JSON.parse(@manifest_path.read) : {}
      end

      def status(locale, recipe)
        key = "#{locale}/#{recipe.fetch('image')}"
        @directory.join(key).file? ? "present" : "missing"
      end

      def store(locale, recipe, source)
        key = "#{locale}/#{recipe.fetch('image')}"
        destination = @directory.join(key)
        raise "Capture missing: #{source}" unless Pathname(source).file?
        atomic_write(destination, File.binread(source))
        @manifest[key] = {"generated_at" => Time.now.utc.iso8601}
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
