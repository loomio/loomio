# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require "tmpdir"
require_relative "../../docs/sync_translations"

class DocsTranslationSyncTest < Minitest::Test
  L = Docs::Localization
  PAGE = "user_manual/example.md"

  def setup
    @root = Pathname(Dir.mktmpdir("manual-sync"))
    @root.join("SUMMARY.md").write("- [Example](#{PAGE})\n- [Changelog](user_manual/changelog/index.md)\n- [Privacy](policy/privacy.md)\n")
    @english = L.annotate("# Example\n\nRead this page.\n")
    @sections = L.parse(@english).sections
    @translated = [L::Section.new(id: "introduction", text: "# Exemple\n\nLisez cette page.")]
    @metadata = {"title" => "Exemple", "title_source" => L.text_hash("Example"),
      "sections" => @sections.to_h { |s| [s.id, s.text_hash] },
      "generated" => @translated.to_h { |s| [s.id, s.text_hash] }}
    write("en/#{PAGE}", @english)
    write("fr/#{PAGE}", L.dump(@metadata, @translated))
    @requests = []
    @runner = Object.new
    @runner.define_singleton_method(:translate) { |paths| [] }
    @sync = Docs::TranslationSync.new(root: @root, locales: [L.locale("fr")], translator: ->(locale) { @requests << locale; @runner })
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def test_current_pages_do_not_start_the_translator
    with_paths { assert_empty @sync.update }
    assert_empty @requests
    assert_equal [PAGE], @sync.paths.keys
  end

  def test_changed_english_runs_only_the_affected_page_and_reports_generated_files
    write("en/#{PAGE}", @english.sub("Read this page.", "Read this guide."))
    run = ->(paths) do
      assert_equal [PAGE], paths
      source = L.parse(@root.join("en", PAGE).read)
      metadata = @metadata.merge("sections" => source.sections.to_h { |s| [s.id, s.text_hash] })
      write("fr/#{PAGE}", L.dump(metadata, @translated))
      []
    end
    @runner.stub(:translate, run) do
      with_paths { assert_equal ["docs/fr/#{PAGE}"], @sync.update }
    end
    assert_equal ["fr"], @requests
  end

  def test_customer_corrections_reach_the_existing_translator_without_english_changes
    write("fr/#{PAGE}", L.dump(@metadata, [@translated.first.with(text: "# Exemple\n\nConsultez cette page.")]))
    @runner.stub(:translate, ->(paths) { assert_equal [PAGE], paths; [] }) do
      with_paths { assert_empty @sync.update }
    end
    assert_equal ["fr"], @requests
  end

  def test_retranslation_runs_every_page_in_parallel_and_collects_failures
    pages = %w[user_manual/one.md user_manual/two.md user_manual/three.md]
    @root.join("SUMMARY.md").write(pages.map { |page| "- [#{page}](#{page})\n" }.join)
    pages.each { |page| write("en/#{page}", @english) }
    translated = Queue.new
    running = Queue.new
    concurrent = 0
    runner = Object.new
    runner.define_singleton_method(:translate) do |paths|
      running << 1
      concurrent = [concurrent, running.size].max
      sleep 0.05
      running.pop
      translated << paths.first
      paths.first.include?("two") ? ["#{paths.first}: failed"] : []
    end
    sync = Docs::TranslationSync.new(root: @root, locales: [L.locale("fr")], translator: ->(_locale) { runner }, retranslate: true, jobs: 3)
    error = with_paths { assert_raises(RuntimeError) { sync.update } }
    assert_includes error.message, "fr: user_manual/two.md: failed"
    assert_equal pages.sort, Array.new(translated.size) { translated.pop }.sort
    assert_operator concurrent, :>, 1
  end

  def test_check_rejects_stale_pages_without_starting_the_translator
    write("en/#{PAGE}", @english.sub("Read this page.", "Read this guide."))
    with_paths do
      error = assert_raises(RuntimeError) { @sync.validate! }
      assert_includes error.message, "stale section introduction"
    end
    assert_empty @requests
  end

  def test_check_rejects_invalid_customer_link_changes
    write("en/#{PAGE}", @english.sub("Read this page.", "Read [this page](/en/example)."))
    source = L.parse(@root.join("en", PAGE).read)
    metadata = @metadata.merge("sections" => source.sections.to_h { |s| [s.id, s.text_hash] })
    write("fr/#{PAGE}", L.dump(metadata, @translated))
    with_paths do
      error = assert_raises(RuntimeError) { @sync.validate! }
      assert_includes error.message, "link targets differ"
    end
  end

  private

  def write(path, text)
    file = @root.join(path)
    FileUtils.mkdir_p(file.dirname)
    file.write(text)
  end

  def with_paths(&block)
    L.stub(:path, ->(locale, path) { @root.join(locale, path) }, &block)
  end
end
