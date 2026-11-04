# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require "tmpdir"
require_relative "../../docs/help/corrections"

class DocsCorrectionsTest < Minitest::Test
  def test_generated_translation_baselines_remain_available_across_the_help_site_move
    Dir.mktmpdir do |directory|
      root = Pathname(directory).join("docs/help")
      section = Docs::Localization::Section.new(id: "introduction", text: "# Exemple\n\nTexte original.")
      baseline = Docs::Localization.dump({}, [section])
      changed = Docs::Localization.dump({}, [section.with(text: "# Exemple\n\nTexte corrigé.")])
      paths = ["docs/help/fr/user_manual/example.md", "docs/fr/user_manual/example.md", "docs/translations/fr/user_manual/example.yml"]
      files = {
        "after-move:#{paths.first}" => changed,
        "before-move:#{paths[1]}" => baseline
      }
      capture = lambda do |*arguments, **options|
        assert_equal "git", arguments.first
        if arguments[1] == "log"
          assert_equal paths, arguments.drop(4)
          assert_equal directory, options.fetch(:chdir)
          ["after-move\nbefore-move\n", Struct.new(:success?).new(true)]
        else
          assert_equal "show", arguments[1]
          text = files[arguments[2]]
          [text.to_s, Struct.new(:success?).new(!text.nil?)]
        end
      end

      result = Open3.stub(:capture2, capture) do
        Docs::Corrections.generated_text(root, "fr", "user_manual/example.md", section, section.text_hash)
      end

      assert_equal section.text, result
    end
  end
end
