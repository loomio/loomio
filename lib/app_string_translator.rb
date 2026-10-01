# frozen_string_literal: true

require "json"
require_relative "codex_translator"
require_relative "translation_glossary"

# Translates Loomio's interface strings (config/locales/{client,server}.en.yml)
# into one locale with the codex translator and Loomio's glossary.
#
# Strings go in batches, each with the existing translations of neighbouring
# keys as context so new wording matches the old. Every reply is checked: the
# interpolation variables and HTML tags must match the English, and a
# rendering the glossary marks as wrong gets one retry with the problem
# explained. Strings that still fail are reported and left untranslated.
class AppStringTranslator
  BATCH_SIZE = 40
  CONTEXT_SIZE = 30

  Result = Data.define(:translations, :failures)

  # `existing` maps keys to the locale's current translations, used as
  # context. The language name and style come from the glossary.
  def initialize(locale, existing:, translator: CodexTranslator.method(:call))
    @locale = locale
    @existing = existing
    @translator = translator
  end

  # Translates {key => English} and returns the translations that passed
  # their checks, with a failure message for each key that did not. With
  # `current` translations, revises them to follow the glossary instead of
  # starting afresh, so wording that is already right stays. Yields each
  # batch's translations as it finishes, so callers can save as they go.
  def translate(strings, current: {})
    translations = {}
    failures = {}
    strings.each_slice(BATCH_SIZE) do |batch|
      batch = batch.to_h
      reply = request(batch, current.slice(*batch.keys), {})
      passed, problems = check(batch, reply, current)
      if problems.any?
        retry_batch = batch.slice(*problems.keys)
        retried, problems = check(retry_batch, request(retry_batch, current.slice(*retry_batch.keys), problems), current)
        passed.merge!(retried)
      end
      translations.merge!(passed)
      failures.merge!(problems.transform_values { |messages| messages.join("; ") })
      yield passed if block_given?
    end
    Result.new(translations: translations, failures: failures)
  end

  private

  def request(batch, current, problems)
    prompt = <<~PROMPT
      Translate these Loomio interface strings from English into #{TranslationGlossary.language(@locale)} (#{@locale}).
      Loomio is a collaborative decision-making app used by cooperatives, unions, associations and community groups.
      Reply only with JSON mapping each key to its translation: {"key": "translation"}.
      #{TranslationGlossary.style(@locale)}
      Write plain, calm interface copy in the everyday words people use with their peers. Interface space is tight: keep each translation as short as the English allows, and prefer the shorter of two equally clear words. Do not add exclamation marks. Omit the final full stop when the English is a single sentence without one.
      Keep every %{variable}, HTML tag, Markdown mark and line break exactly as in the English. Do not translate variable names.
      The key names say where a string appears; use them to choose the right sense of a word.
      Use Loomio's terminology wherever the English uses these terms in their Loomio sense, inflected as the grammar requires:
      #{TranslationGlossary.prompt(@locale, english: batch.values.join("\n"))}
      Existing translations of nearby strings, for consistent wording:
      #{JSON.pretty_generate(context_for(batch.keys))}
      Strings to translate:
      #{JSON.pretty_generate(batch)}
      #{"Current translations of these strings. Revise each one only where it does not use Loomio's terminology for a term in its Loomio sense, or is wrong; otherwise return it unchanged:\n#{JSON.pretty_generate(current)}" if current.any?}
      #{"Problems with your previous translations of these strings, to fix:\n#{JSON.pretty_generate(problems)}" if problems.any?}
    PROMPT
    response = @translator.call(prompt).strip.sub(/\A```(?:json)?\s*/, "").sub(/\s*```\z/, "")
    reply = JSON.parse(response)
    raise "Translator response must be an object" unless reply.is_a?(Hash)

    reply
  rescue JSON::ParserError
    {}
  end

  # A revision returned unchanged means the model judged that the English word
  # is not the Loomio term there (a "code block" is not a block), so only its
  # structure is checked.
  def check(batch, reply, current)
    passed = {}
    problems = {}
    batch.each do |key, english|
      translation = reply[key]
      messages = if translation.is_a?(String) && !translation.strip.empty?
        unchanged = translation == current[key]
        structure_problems(english, translation) + (unchanged ? [] : TranslationGlossary.wrong_terms(english, translation, @locale))
      else
        ["missing translation"]
      end
      messages.empty? ? passed[key] = translation : problems[key] = messages
    end
    [passed, problems]
  end

  def structure_problems(english, translation)
    problems = []
    problems << "variables differ from the English" if variables(english) != variables(translation)
    problems << "HTML tags differ from the English" if tags(english) != tags(translation)
    problems
  end

  def variables(text)
    text.scan(/%\{\w+\}/).sort
  end

  def tags(text)
    text.scan(%r{</?[a-z][a-z0-9]*}i).map(&:downcase).sort
  end

  # Existing translations of keys sharing the batch's namespaces, nearest
  # namespace first.
  def context_for(keys)
    prefixes = keys.map { |key| key.split(".")[0..-2].join(".") }.uniq
    @existing.select { |key, _| prefixes.any? { |prefix| key.start_with?("#{prefix}.") } && !keys.include?(key) }
      .first(CONTEXT_SIZE).to_h
  end
end
