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

  def test_cache_tracks_missing_and_present_without_retaining_history
    Dir.mktmpdir do |directory|
      cache = Docs::Screenshots::Cache.new(directory)
      source = File.join(directory, "capture.png")
      File.binwrite(source, "first PNG")
      assert_equal "missing", cache.status("fr", recipe)
      cache.store("fr", recipe, source)
      assert_equal "present", cache.status("fr", recipe)
      File.binwrite(source, "replacement PNG")
      cache.store("fr", recipe, source)
      target = File.join(directory, "fr", recipe.fetch("image"))
      assert_equal "replacement PNG", File.binread(target)
      assert_equal 1, Dir[File.join(directory, "fr/**/*.png")].length
      manifest = JSON.parse(File.read(File.join(directory, ".generation.json")))
      assert_equal 1, manifest.length
      assert manifest.fetch("fr/#{recipe.fetch('image')}").key?("generated_at")
      refute manifest.fetch("fr/#{recipe.fetch('image')}").key?("inputs")
      assert_equal "present", Docs::Screenshots::Cache.new(directory).status("fr", recipe)
      File.unlink(target)
      assert_equal "missing", Docs::Screenshots::Cache.new(directory).status("fr", recipe)
    end
  end

  def test_failed_capture_keeps_existing_image_and_manifest
    Dir.mktmpdir do |directory|
      cache = Docs::Screenshots::Cache.new(directory)
      source = File.join(directory, "capture.png")
      File.binwrite(source, "existing PNG")
      cache.store("fr", recipe, source)
      manifest = File.binread(File.join(directory, ".generation.json"))
      assert_raises(RuntimeError) { cache.store("fr", recipe, File.join(directory, "missing.png")) }
      assert_equal "existing PNG", File.binread(File.join(directory, "fr", recipe.fetch("image")))
      assert_equal manifest, File.binread(File.join(directory, ".generation.json"))
    end
  end

  def test_present_cache_skips_the_browser_runner_even_with_legacy_fingerprints
    Dir.mktmpdir do |directory|
      source = Docs::Screenshots::ROOT.join("docs/en", recipe.fetch("image"))
      cache = Docs::Screenshots::Cache.new(directory)
      cache.store("fr", recipe, source)
      manifest_path = File.join(directory, ".generation.json")
      manifest = JSON.parse(File.read(manifest_path))
      manifest.fetch("fr/#{recipe.fetch('image')}")["inputs"] = "obsolete fingerprint"
      File.write(manifest_path, JSON.generate(manifest))
      output, status = Open3.capture2(RbConfig.ruby, Docs::Screenshots::ROOT.join("bin/docs-screenshots").to_s,
        "fr", recipe.fetch("image"), "--output", directory)
      assert status.success?, output
      assert_includes output, "0 missing, 1 present"
      refute_includes output, "Building Vue"
    end
  end

  def test_literal_interface_expectations_use_the_selected_language
    assert_includes Docs::Screenshots.labels("fr").fetch("Bookmarks"), "Signets"
  end

  def test_local_publishing_uploads_only_selected_images_and_the_language_manifest
    with_local_publisher do |directory, remote, log|
      output, status = Open3.capture2(RbConfig.ruby, Docs::Screenshots::ROOT.join("bin/docs-screenshots").to_s,
        "fr", recipe.fetch("image"), "--publish", "--output", directory)
      assert status.success?, output
      assert_includes output, "0 missing, 1 present"
      refute_includes output, "Building Vue"
      key = "fr/#{recipe.fetch('image')}"
      assert_equal "selected PNG", File.binread(File.join(remote, key))
      assert_equal [key, "fr/.generation.json"], File.readlines(log, chomp: true)
      manifest = JSON.parse(File.read(File.join(remote, "fr/.generation.json")))
      assert_equal [key], manifest.keys
      assert_equal({"generated_at" => "2026-10-02T00:00:00Z"}, manifest.fetch(key))
    end
  end

  def test_failed_local_upload_keeps_the_previous_hosted_manifest
    with_local_publisher do |directory, remote, log|
      ENV["FAIL_IMAGE_UPLOAD"] = "1"
      manifest_path = File.join(remote, "fr/.generation.json")
      FileUtils.mkdir_p(File.dirname(manifest_path))
      File.write(manifest_path, "previous manifest")
      refute Docs::Screenshots.publish("fr", [recipe], directory)
      assert_equal "previous manifest", File.read(manifest_path)
      assert_equal ["fr/#{recipe.fetch('image')}"], File.readlines(log, chomp: true)
    end
  end

  private

  def with_local_publisher
    variables = %w[PATH PUBLISH_REMOTE PUBLISH_LOG FAIL_IMAGE_UPLOAD]
    previous = ENV.to_h.slice(*variables)
    Dir.mktmpdir do |directory|
      bin = File.join(directory, "bin")
      remote = File.join(directory, "remote")
      log = File.join(directory, "uploads.log")
      FileUtils.mkdir_p(bin)
      File.write(File.join(bin, "cf"), <<~BASH)
        #!/usr/bin/env bash
        set -euo pipefail
        [ "${12}" = "--mode" ] && [ "${13}" = "development" ]
        printf '%s\\n' "$4" >> "$PUBLISH_LOG"
        if [ -n "${FAIL_IMAGE_UPLOAD+x}" ] && [[ "$4" == *.png ]]; then exit 73; fi
        mkdir -p "$PUBLISH_REMOTE/$(dirname "$4")"
        cp "$8" "$PUBLISH_REMOTE/$4"
      BASH
      FileUtils.chmod(0o755, File.join(bin, "cf"))
      ENV["PATH"] = "#{bin}:#{ENV.fetch('PATH')}"
      ENV["PUBLISH_REMOTE"] = remote
      ENV["PUBLISH_LOG"] = log
      ENV.delete("FAIL_IMAGE_UPLOAD")
      key = "fr/#{recipe.fetch('image')}"
      image = File.join(directory, key)
      FileUtils.mkdir_p(File.dirname(image))
      File.binwrite(image, "selected PNG")
      File.write(File.join(directory, ".generation.json"), JSON.generate({
        key => {"generated_at" => "2026-10-02T00:00:00Z", "inputs" => "legacy"},
        "de/#{recipe.fetch('image')}" => {"generated_at" => "2026-10-01T00:00:00Z"}
      }))
      yield directory, remote, log
    end
  ensure
    variables.each { |name| previous.key?(name) ? ENV[name] = previous.fetch(name) : ENV.delete(name) }
  end
end
