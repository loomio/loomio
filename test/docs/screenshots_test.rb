require "minitest/autorun"
require "tmpdir"
require_relative "../../docs/screenshots"

class DocsScreenshotsTest < Minitest::Test
  def recipe
    Docs::Screenshots.images.fetch("user_manual/users/bookmarks/save_bookmark.png")
  end

  def test_catalog_resolves_composed_names_and_excludes_unapproved_assets
    assert_equal "bookmarks.js", recipe.fetch("spec")
    assert_equal "save_bookmark", recipe.fetch("testcase")
    assert Docs::Screenshots.images.key?("guides/making_decisions/proposal_consensus_process_refresh_brand.png")
    refute Docs::Screenshots.images.key?("guides/facilitators_guide/collaboration-process.png")
    assert Docs::Screenshots.catalog.all? { |entry| Docs::Screenshots::ROOT.join("docs/en", entry.fetch("image")).file? }
  end

  def test_cache_tracks_missing_current_and_outdated_without_retaining_history
    Dir.mktmpdir do |directory|
      cache = Docs::Screenshots::Cache.new(directory)
      source = File.join(directory, "capture.png")
      File.binwrite(source, "first PNG")
      assert_equal "missing", cache.status("fr", recipe, "old")
      cache.store("fr", recipe, "old", source)
      assert_equal "current", cache.status("fr", recipe, "old")
      assert_equal "outdated", cache.status("fr", recipe, "new")
      File.binwrite(source, "replacement PNG")
      cache.store("fr", recipe, "new", source)
      target = File.join(directory, "fr", recipe.fetch("image"))
      assert_equal "replacement PNG", File.binread(target)
      assert_equal 1, Dir[File.join(directory, "fr/**/*.png")].length
      manifest = JSON.parse(File.read(File.join(directory, ".generation.json")))
      assert_equal 1, manifest.length
      assert_equal "new", manifest.fetch("fr/#{recipe.fetch('image')}").fetch("inputs")
      assert_equal "current", Docs::Screenshots::Cache.new(directory).status("fr", recipe, "new")
      File.unlink(target)
      assert_equal "missing", Docs::Screenshots::Cache.new(directory).status("fr", recipe, "new")
    end
  end

  def test_failed_capture_keeps_existing_image_and_manifest
    Dir.mktmpdir do |directory|
      cache = Docs::Screenshots::Cache.new(directory)
      source = File.join(directory, "capture.png")
      File.binwrite(source, "existing PNG")
      cache.store("fr", recipe, "old", source)
      manifest = File.binread(File.join(directory, ".generation.json"))
      assert_raises(RuntimeError) { cache.store("fr", recipe, "new", File.join(directory, "missing.png")) }
      assert_equal "existing PNG", File.binread(File.join(directory, "fr", recipe.fetch("image")))
      assert_equal manifest, File.binread(File.join(directory, ".generation.json"))
    end
  end

  def test_current_cache_skips_the_browser_runner
    Dir.mktmpdir do |directory|
      source = Docs::Screenshots::ROOT.join("docs/en", recipe.fetch("image"))
      cache = Docs::Screenshots::Cache.new(directory)
      cache.store("fr", recipe, Docs::Screenshots.fingerprint(recipe, "fr"), source)
      output, status = Open3.capture2(RbConfig.ruby, Docs::Screenshots::ROOT.join("bin/docs-screenshots").to_s,
        "fr", recipe.fetch("image"), "--output", directory)
      assert status.success?, output
      assert_includes output, "0 missing, 1 current, 0 outdated"
      refute_includes output, "Building Vue"
    end
  end

  def test_locale_changes_inputs_and_literal_interface_expectations
    refute_equal Docs::Screenshots.fingerprint(recipe, "fr"), Docs::Screenshots.fingerprint(recipe, "de")
    assert_includes Docs::Screenshots.labels("fr").fetch("Bookmarks"), "Signets"
  end
end
