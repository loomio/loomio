# frozen_string_literal: true

require "yaml"

# Loomio's terminology for each locale, from config/locales/glossary.yml. The
# app string translator and the user manual translator both give it to the
# model and check replies against it. Plain Ruby, so the documentation tools
# can use it without booting Rails.
module TranslationGlossary
  PATH = File.expand_path("../config/locales/glossary.yml", __dir__)

  # english_pattern matches the English term with its regular plural and verb
  # endings.
  Entry = Data.define(:term, :means, :use, :avoid, :stems, :note, :english_pattern)

  def self.data
    @data ||= YAML.safe_load_file(PATH)
  end

  def self.terms
    data.fetch("terms")
  end

  # The language's English name, for prompts.
  def self.language(locale)
    data.fetch("locales").fetch(locale).fetch("name")
  end

  # Register and conventions the translators follow for the locale.
  def self.style(locale)
    data.fetch("locales").fetch(locale).fetch("style")
  end

  # Entries for one app locale (such as "fr" or "pt_BR"), in glossary order.
  # Terms the locale has no entry for are omitted.
  def self.entries(locale)
    @entries ||= {}
    @entries[locale] ||= terms.filter_map do |term, info|
      value = info[locale]
      next unless value

      value = {"use" => value} if value.is_a?(String)
      Entry.new(term: term, means: info.fetch("means"), use: value.fetch("use"),
        avoid: Array(value["avoid"]), stems: Array(value.fetch("stems", [value.fetch("use")])).map { |stem| normalize(stem) },
        note: value["note"], english_pattern: /\b#{Regexp.escape(term)}(?:s|es|d|ed|ing)?\b/i)
    end
  end

  # The glossary as prompt text: each term with its Loomio meaning and the
  # locale's preferred translation. Given the English being translated, only
  # the terms it uses are listed, which keeps requests short and focused.
  def self.prompt(locale, english: nil)
    relevant = english ? entries(locale).select { |entry| english.match?(entry.english_pattern) } : entries(locale)
    relevant.map do |entry|
      line = "- #{entry.term} → #{entry.use} (#{entry.means})"
      line += " Avoid: #{entry.avoid.join(", ")}." if entry.avoid.any?
      line += " #{entry.note}" if entry.note
      line
    end.join("\n")
  end

  # Renderings the glossary marks as wrong for a term the English uses. A
  # reliable signal, so translators retry when they find one.
  def self.wrong_terms(english, translation, locale)
    text = normalize(translation)
    entries(locale).filter_map do |entry|
      next unless english.match?(entry.english_pattern)

      wrong = entry.avoid.find { |avoid| contains_word?(remove_stems(text, entry), normalize(avoid)) }
      %(use "#{entry.use}" instead of "#{wrong}" for "#{entry.term}") if wrong
    end
  end

  # Terms the English uses whose preferred translation does not appear. Only a
  # hint: English words such as "block" or "round" are not always Loomio terms,
  # and a translation may rightly rephrase. Use it to find strings to review.
  def self.missing_terms(english, translation, locale)
    text = normalize(translation)
    entries(locale).filter_map do |entry|
      next unless english.match?(entry.english_pattern)

      %(expected "#{entry.use}" for "#{entry.term}") if entry.stems.none? { |stem| text.include?(stem) }
    end
  end

  # Lowercases for matching. Lowercase Turkish İ is i with a combining dot
  # above, which would stop "itiraz" matching "İtiraz", so the dot is dropped.
  def self.normalize(text)
    text.downcase.delete("\u0307")
  end

  # A wrong rendering can be part of the correct one, as French "fil" is part
  # of "fil de discussion", so look for it only outside the correct forms.
  def self.remove_stems(text, entry)
    entry.stems.sort_by { |stem| -stem.length }.reduce(text) { |remaining, stem| remaining.gsub(stem, " ") }
  end

  # Whole-word match where words are separated by spaces; substring match for
  # scripts written without spaces, such as Japanese and Chinese.
  def self.contains_word?(text, word)
    return text.include?(word) if word.match?(/\p{Han}|\p{Hiragana}|\p{Katakana}/)

    text.match?(/(?<![\p{L}\p{M}])#{Regexp.escape(word)}(?![\p{L}\p{M}])/)
  end
end
