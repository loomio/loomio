require "test_helper"

class TranslationGlossaryTest < ActiveSupport::TestCase
  GLOSSARY = {
    "locales" => {"fr" => {"name" => "French", "style" => "Use vous."}, "tr" => {"name" => "Turkish", "style" => "Use siz."}},
    "terms" => {
      "thread" => {"means" => "A conversation.", "fr" => {"use" => "fil de discussion", "avoid" => ["fil"], "stems" => ["fil de discussion", "fils de discussion"]}},
      "outcome" => {"means" => "The closing statement.", "fr" => {"use" => "conclusion", "avoid" => ["résultat"], "stems" => ["conclusion"]}},
      "objection" => {"means" => "A reasoned concern.", "tr" => {"use" => "İtiraz", "stems" => ["itiraz"]}},
      "time poll" => {"means" => "Finding a time.", "fr" => "sondage horaire"}
    }
  }.freeze

  def with_glossary(&block)
    TranslationGlossary.instance_variable_set(:@entries, nil)
    TranslationGlossary.stub(:data, GLOSSARY, &block)
  ensure
    TranslationGlossary.instance_variable_set(:@entries, nil)
  end

  test "the shipped glossary covers every supported locale and term" do
    data = TranslationGlossary.data
    assert_equal (AppConfig.locales["supported"] - ["en"]).sort, data.fetch("locales").keys.sort
    data.fetch("terms").each do |term, info|
      assert info["means"].present?, "#{term} needs a meaning"
      data.fetch("locales").each_key do |locale|
        entry = info.fetch(locale) { flunk "#{term} has no #{locale} entry" }
        stems = Array(entry["stems"]).map { |stem| TranslationGlossary.normalize(stem) }
        assert stems.any? { |stem| TranslationGlossary.normalize(entry["use"]).include?(stem) }, "#{locale} #{term}: no stem matches its preferred term"
      end
    end
  end

  test "every locale keeps thread, discussion, outcome and results apart" do
    terms = TranslationGlossary.data.fetch("terms")
    [%w[thread discussion], %w[outcome results], %w[poll vote]].each do |first, second|
      TranslationGlossary.data.fetch("locales").each_key do |locale|
        one = TranslationGlossary.normalize(terms.dig(first, locale, "use"))
        two = TranslationGlossary.normalize(terms.dig(second, locale, "use"))
        next if first == "poll" && locale.start_with?("zh")

        distinct = first == "poll" ? one != two : one != two && !one.include?(two) && !two.include?(one)
        assert distinct, "#{locale}: #{first} (#{one}) and #{second} (#{two}) must differ"
      end
    end
  end

  test "the prompt lists each term with its meaning and preferred translation" do
    with_glossary do
      prompt = TranslationGlossary.prompt("fr")
      assert_includes prompt, "- thread → fil de discussion (A conversation.) Avoid: fil."
      assert_includes prompt, "- time poll → sondage horaire (Finding a time.)"
      assert_equal "Use vous.", TranslationGlossary.style("fr")
      assert_equal "French", TranslationGlossary.language("fr")
    end
  end

  test "the prompt can list only the terms the English uses" do
    with_glossary do
      prompt = TranslationGlossary.prompt("fr", english: "Share the outcome")
      assert_includes prompt, "outcome → conclusion"
      assert_not_includes prompt, "thread"
    end
  end

  test "wrong terms are found only where the English uses the term" do
    with_glossary do
      assert_equal [%(use "conclusion" instead of "résultat" for "outcome")],
        TranslationGlossary.wrong_terms("Share the outcome", "Partager le résultat", "fr")
      assert_empty TranslationGlossary.wrong_terms("Results", "Résultats", "fr")
    end
  end

  test "a wrong rendering inside the preferred term is not reported" do
    with_glossary do
      assert_empty TranslationGlossary.wrong_terms("Move thread", "Déplacer le fil de discussion", "fr")
      assert_equal [%(use "fil de discussion" instead of "fil" for "thread")],
        TranslationGlossary.wrong_terms("Move thread", "Déplacer le fil", "fr")
      assert_empty TranslationGlossary.wrong_terms("Move thread", "Profil", "fr")
    end
  end

  test "missing terms are hints for strings that do not use the preferred term" do
    with_glossary do
      assert_equal [%(expected "fil de discussion" for "thread")], TranslationGlossary.missing_terms("New threads", "Nouvelles discussions", "fr")
      assert_empty TranslationGlossary.missing_terms("New threads", "Nouveaux fils de discussion", "fr")
    end
  end

  test "Turkish dotted capital I matches its lowercase stem" do
    with_glossary do
      assert_empty TranslationGlossary.missing_terms("Objection", "İtiraz", "tr")
    end
  end
end
