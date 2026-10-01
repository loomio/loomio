# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require "tmpdir"
require_relative "../../docs/translate"

class DocsLocalizationTest < Minitest::Test
  L = Docs::Localization
  PAGE = "user_manual/example.md"

  def setup
    @root = Pathname(Dir.mktmpdir("docs-localization"))
    @english = L.annotate("# Example\n\nIntroduction.\n\n## Save\n\nSave the item.\n\n![](save.png)\n")
    @sections = L.parse(@english).sections
    @translations = [L::Section.new(id: "introduction", text: "# Exemple\n\nIntroduction."),
      L::Section.new(id: "save", text: "## Enregistrer\n\nEnregistrez l’élément.\n\n![](save.png)")]
    @baseline = @translations.to_h { |section| [section.id, section.text] }
    @metadata = {"title" => "Exemple", "title_source" => L.text_hash("Example"), "title_generated" => L.text_hash("Exemple"),
      "sections" => @sections.to_h { |section| [section.id, section.text_hash] },
      "generated" => @translations.to_h { |section| [section.id, section.text_hash] }}
    @source_file = @root.join("en", PAGE)
    FileUtils.mkdir_p(@source_file.dirname)
    @source_file.write(@english)
    @root.join("SUMMARY.md").write("# Manual\n- [Example](#{PAGE})\n")
    write_translation
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def test_customer_can_split_a_paragraph_without_touching_metadata
    text = @translations.first.text.sub("Introduction.", "Première phrase.\n\nDeuxième phrase.")
    @translations[0] = @translations.first.with(text: text)
    write_translation
    with_paths do
      body, problems = L.assemble("fr", PAGE, @english)
      assert_empty problems
      assert_includes body, "Deuxième phrase."
      assert L.load("fr", PAGE).corrected?("introduction")
    end
  end

  def test_heading_rename_keeps_the_same_section_identity
    renamed = @english.sub("## Save", "## Keep")
    assert_equal %w[introduction save], L.parse(L.annotate(renamed)).sections.map(&:id)
    with_paths do
      body, problems = L.assemble("fr", PAGE, renamed)
      assert_nil body
      assert_equal ["stale section save"], problems
    end
  end

  def test_duplicate_section_ids_are_rejected
    assert_raises(RuntimeError) { L.parse(@english.sub("translation-section: save", "translation-section: introduction")) }
  end

  def test_section_markers_and_headings_inside_fences_are_literal
    markdown = "# Example\n\n````markdown\n## Literal\n```\n<!-- translation-section: fake -->\n````\n\n~~~\n## Also literal\n~~~\n\n## Real\n"
    sections = L.parse(L.annotate(markdown)).sections
    assert_equal %w[introduction real], sections.map(&:id)
    assert_includes sections.first.text, "translation-section: fake"
  end

  def test_manual_edits_cannot_change_link_or_image_targets
    @translations[1] = @translations[1].with(text: @translations[1].text.sub("save.png", "missing.png"))
    write_translation
    with_paths do
      body, problems = L.assemble("fr", PAGE, @english)
      assert_nil body
      assert_includes problems, "save: image targets differ from the English"
    end
  end

  def test_structure_validation_preserves_code_tables_lists_and_alerts
    text = "# Example\n\n> [!NOTE]\n> Read `command`.\n\n- One\n- Two\n\n| A | B |\n|---|---|\n| C | D |\n"
    assert_empty Docs::Markdown.errors(text, text.sub("Read", "Lisez"))
    assert_includes Docs::Markdown.errors(text, text.sub("`command`", "`other`")), "code differ from the English"
    assert_includes Docs::Markdown.errors(text, text.sub("- Two", "Two")), "lists differ from the English"
    assert_includes Docs::Markdown.errors(text, text.sub("| C | D |", "| C | D |\n| E | F |")), "tables differ from the English"
    assert_includes Docs::Markdown.errors(text, text.sub("[!NOTE]", "[!TIP]")), "alert markers differ from the English"
  end

  def test_missing_or_reordered_sections_are_not_publishable
    write_translation(@translations.reverse)
    with_paths do
      assert_includes L.assemble("fr", PAGE, @english).last, "section order"
    end
    write_translation(@translations.take(1))
    with_paths { assert_includes L.assemble("fr", PAGE, @english).last, "save" }
  end

  def test_unchanged_page_makes_no_request_and_writes_nothing
    original = translation_path.read
    translator = translator_with(->(_prompt) { flunk "Unchanged page requested translation" })
    assert_empty update(translator)
    assert_equal original, translation_path.read
  end

  def test_only_changed_machine_section_is_retranslated_and_correction_survives
    @translations[0] = @translations.first.with(text: "# Exemple\n\nUne correction du client.")
    write_translation
    @source_file.write(@english.sub("Save the item.", "Save this item."))
    requests = []
    translator = translator_with(lambda do |prompt|
      requests << prompt
      {navigation_title: "Exemple", sections: {save: "## Enregistrer\n\nEnregistrez cet élément.\n\n![](save.png)"}}.to_json
    end)
    assert_empty update(translator)
    assert_equal 1, requests.length
    assert_includes translation_path.read, "Une correction du client."
    with_paths do
      assert L.load("fr", PAGE).corrected?("introduction")
      refute L.load("fr", PAGE).corrected?("save")
      assert_empty L.assemble("fr", PAGE, @source_file.read).last
    end
  end

  def test_failed_structural_validation_retains_the_old_section
    @source_file.write(@english.sub("Save the item.", "Save this item."))
    translator = translator_with(->(_prompt) { {navigation_title: "Exemple", sections: {save: "## Enregistrer\n\n![](wrong.png)"}}.to_json })
    failures = update(translator)
    assert failures.any? { |error| error.include?("image targets") }
    with_paths { assert_equal @translations[1].text, L.load("fr", PAGE).by_id.fetch("save").text }
  end

  def test_new_section_is_translated_without_replacing_existing_sections
    @source_file.write(@english + "\n<!-- translation-section: remove -->\n\n## Remove\n\nRemove the item.\n")
    translator = translator_with(->(_prompt) { {navigation_title: "Exemple", sections: {remove: "## Supprimer\n\nSupprimez l’élément."}}.to_json })
    assert_empty update(translator)
    with_paths do
      assert_equal %w[introduction save remove], L.load("fr", PAGE).sections.map(&:id)
      assert_equal @translations.first.text, L.load("fr", PAGE).sections.first.text
    end
  end

  def test_deleting_a_section_needs_no_translation_request
    @source_file.write(L.dump({}, @sections.take(1)))
    translator = translator_with(->(_prompt) { flunk "Deletion needs no model request" })
    assert_empty update(translator)
    with_paths do
      document = L.load("fr", PAGE)
      assert_equal ["introduction"], document.sections.map(&:id)
      refute document.metadata.fetch("sections").key?("save")
      refute document.metadata.fetch("generated").key?("save")
    end
  end

  def test_customer_correction_is_recorded_without_a_translation_request
    @translations[1] = @translations[1].with(text: @translations[1].text.sub("l’élément", "cet élément"))
    write_translation
    translator = translator_with(->(_prompt) { flunk "Learning a correction needs no translation request" })
    assert_empty update(translator)
    notes = Docs::Corrections.notes(translation_path.read)
    assert_equal 1, notes.length
    assert_includes notes.first.fetch("before"), "l’élément"
    assert_includes notes.first.fetch("after"), "cet élément"
    recorded = translation_path.read
    assert_empty update(translator)
    assert_equal recorded, translation_path.read
  end

  def test_corrected_section_updates_automatically_with_correction_context
    @translations[1] = @translations[1].with(text: @translations[1].text.sub("l’élément", "cet élément"))
    write_translation
    @source_file.write(@english.sub("Save the item.", "Save the selected item."))
    prompts = []
    translator = translator_with(lambda do |prompt|
      prompts << prompt
      {navigation_title: "Exemple", sections: {save: "## Enregistrer\n\nEnregistrez cet élément sélectionné.\n\n![](save.png)"}}.to_json
    end)
    assert_empty update(translator)
    assert_includes prompts.first, '"corrections"'
    assert_includes prompts.first, "cet élément"
    assert_equal 1, Docs::Corrections.notes(translation_path.read).length
    with_paths { assert_empty L.assemble("fr", PAGE, @source_file.read).last }
    refute @root.join("_proposals").exist?
  end

  def test_correction_comments_cannot_close_the_html_comment
    comment = Docs::Corrections.record("old", "new --> <script>")
    assert_equal 1, comment.scan("-->").length
    assert_includes Docs::Corrections.notes(comment).first.fetch("after"), "--> <script>"
  end

  def test_requests_receive_corrections_from_other_pages_in_the_language
    other = @root.join("fr/user_manual/other.md")
    note = Docs::Corrections.record("wrong terminology", "preferred terminology")
    other.write(L.dump({"title" => "Autre"}, [L::Section.new(id: "introduction", text: "#{note}\n\n# Autre")]))
    @source_file.write(@english.sub("Save the item.", "Save this item."))
    prompts = []
    translator = translator_with(lambda do |prompt|
      prompts << prompt
      {navigation_title: "Exemple", sections: {save: @translations.last.text}}.to_json
    end)
    assert_empty update(translator)
    assert_includes prompts.first, "preferred terminology"
    assert_includes prompts.first, "user_manual/other.md"
  end

  def test_requests_carry_the_style_and_glossary_and_flag_wrong_terms
    @source_file.write(@english.sub("Save the item.", "Save the outcome."))
    prompts = []
    translator = translator_with(lambda do |prompt|
      prompts << prompt
      {navigation_title: "Exemple", sections: {save: "## Enregistrer\n\nEnregistrez le résultat.\n\n![](save.png)"}}.to_json
    end)
    TranslationGlossary.stub(:prompt, "- outcome → conclusion (The closing statement.)") do
      TranslationGlossary.stub(:wrong_terms, ->(english, translation, locale) {
        assert_equal "fr", locale
        english.include?("outcome") && translation.include?("résultat") ? ['use "conclusion" instead of "résultat" for "outcome"'] : []
      }) do
        assert_empty update(translator)
      end
    end
    assert_includes prompts.first, "- outcome → conclusion"
    assert_includes prompts.first, "vous"
    assert_equal 2, prompts.size, "a wrong term earns one retry"
    with_paths do
      assert_includes L.load("fr", PAGE).metadata.fetch("needs_review").fetch("save"), "instead of"
    end
  end

  def test_retranslation_translates_every_section_but_keeps_corrections_as_context
    @translations[0] = @translations.first.with(text: "# Exemple\n\nUne correction du client.")
    write_translation
    prompts = []
    translator = Docs::PageTranslator.new("fr", root: @root, retranslate: true, translator: lambda do |prompt|
      prompts << prompt
      {navigation_title: "Exemple", sections: {introduction: "# Exemple\n\nIntroduction.", save: "## Enregistrer\n\nEnregistrez l’élément.\n\n![](save.png)"}}.to_json
    end)
    assert_empty update(translator)
    assert_equal 1, prompts.size
    assert_includes prompts.first, "Une correction du client.", "corrected sections keep their text as context"
    refute_includes prompts.first, "Enregistrez l’élément.", "uncorrected sections are translated afresh"
  end

  def test_codex_transport_uses_sol_61_and_reads_the_json_response
    model = ENV.delete("DOCS_TRANSLATOR_MODEL")
    effort = ENV.delete("DOCS_TRANSLATOR_EFFORT")
    command = nil
    stdin = nil
    fake = lambda do |*arguments, stdin_data:|
      command = arguments
      stdin = stdin_data
      File.write(arguments[arguments.index("-o") + 1], '{"sections":{}}')
      ["", Struct.new(:success?).new(true)]
    end
    Open3.stub(:capture2e, fake) do
      assert_equal '{"sections":{}}', Docs::PageTranslator::TRANSLATORS.fetch("codex").call("Translation prompt")
    end
    assert_equal "gpt-6.1-sol", command[command.index("-m") + 1]
    assert_equal "read-only", command[command.index("-s") + 1]
    assert_includes command, "--ephemeral"
    assert_includes command, 'model_reasoning_effort="low"'
    assert_equal "Translation prompt", stdin
  ensure
    ENV["DOCS_TRANSLATOR_MODEL"] = model if model
    ENV["DOCS_TRANSLATOR_EFFORT"] = effort if effort
  end

  private

  def translation_path
    @root.join("fr", PAGE)
  end

  def write_translation(sections = @translations)
    FileUtils.mkdir_p(translation_path.dirname)
    translation_path.write(L.dump(@metadata, sections))
  end

  def with_paths(&block)
    L.stub(:path, ->(locale, page) { @root.join(locale, page) }, &block)
  end

  def translator_with(callable)
    Docs::PageTranslator.new("fr", translator: callable, root: @root)
  end

  def update(translator)
    failures = nil
    capture_io do
      with_paths do
        translator.stub(:source_revision, "baseline") do
          translator.stub(:previous_english, nil) do
            translator.stub(:generated_text, ->(_path, section, _hash) { @baseline[section.id] }) do
              failures = translator.send(:translate_page, PAGE)
            end
          end
        end
      end
    end
    failures
  end
end
