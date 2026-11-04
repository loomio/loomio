require "test_helper"

class AppStringTranslatorTest < ActiveSupport::TestCase
  GLOSSARY = {
    "locales" => {"fr" => {"name" => "French", "style" => "Use vous."}},
    "terms" => {"outcome" => {"means" => "The closing statement.", "fr" => {"use" => "conclusion", "avoid" => ["résultat"], "stems" => ["conclusion"]}}}
  }.freeze

  setup { TranslationGlossary.instance_variable_set(:@entries, nil) }
  teardown { TranslationGlossary.instance_variable_set(:@entries, nil) }

  def translate(strings, replies:, current: {}, existing: {})
    prompts = []
    translator = AppStringTranslator.new("fr", existing: existing, translator: ->(prompt) { prompts << prompt; replies.shift.to_json })
    result = TranslationGlossary.stub(:data, GLOSSARY) { translator.translate(strings, current: current) }
    [result, prompts]
  end

  test "sends the style, glossary and nearby translations, and returns checked translations" do
    result, prompts = translate(
      {"client.outcome.share" => "Share outcome"},
      replies: [{"client.outcome.share" => "Partager la conclusion"}],
      existing: {"client.outcome.edit" => "Modifier la conclusion", "client.other.save" => "Enregistrer"}
    )

    assert_equal({"client.outcome.share" => "Partager la conclusion"}, result.translations)
    assert_empty result.failures
    assert_includes prompts.first, "into French (fr)"
    assert_includes prompts.first, "Use vous."
    assert_includes prompts.first, "- outcome → conclusion"
    assert_includes prompts.first, "Modifier la conclusion"
    assert_not_includes prompts.first, "Enregistrer"
  end

  test "retries a wrong term once with the problem explained" do
    result, prompts = translate(
      {"client.outcome.share" => "Share outcome"},
      replies: [{"client.outcome.share" => "Partager le résultat"}, {"client.outcome.share" => "Partager la conclusion"}]
    )

    assert_equal({"client.outcome.share" => "Partager la conclusion"}, result.translations)
    assert_equal 2, prompts.size
    assert_includes prompts.last, %(use \\"conclusion\\" instead of \\"résultat\\")
  end

  test "rejects translations that change interpolation variables or HTML tags" do
    result, _prompts = translate(
      {"client.a" => "Hello %{name}", "client.b" => "<strong>Vote</strong>"},
      replies: [{"client.a" => "Bonjour %{nom}", "client.b" => "Voter"}, {"client.a" => "Bonjour %{nom}", "client.b" => "Voter"}]
    )

    assert_empty result.translations
    assert_equal "variables differ from the English", result.failures["client.a"]
    assert_equal "HTML tags differ from the English", result.failures["client.b"]
  end

  test "a revision returned unchanged is kept even when it contains an avoided word" do
    result, prompts = translate(
      {"client.formatting.result_block" => "Outcome block"},
      current: {"client.formatting.result_block" => "Bloc de résultat"},
      replies: [{"client.formatting.result_block" => "Bloc de résultat"}]
    )

    assert_equal({"client.formatting.result_block" => "Bloc de résultat"}, result.translations)
    assert_equal 1, prompts.size
  end

  test "revising sends the current translations and asks to keep correct wording" do
    _result, prompts = translate(
      {"client.outcome.share" => "Share outcome"},
      current: {"client.outcome.share" => "Partager le résultat"},
      replies: [{"client.outcome.share" => "Partager la conclusion"}]
    )

    assert_includes prompts.first, "Current translations of these strings"
    assert_includes prompts.first, "Partager le résultat"
  end
end
