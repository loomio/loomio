class ClientTranslationService
  attr_reader :locale

  def initialize(locale = nil)
    @locale = (Loomio::I18n::FALLBACKS[locale] || I18n.default_locale).to_s
  end

  def as_json
    @json ||= base.deep_merge(core_translations).deep_merge(plugin_translations)
  end

  private

  def base
    if locale != I18n.default_locale.to_s
      self.class.new(I18n.default_locale.to_s).as_json
    else
      {}
    end
  end

  def core_translations
    Hash(YAML.load_file("config/locales/client.#{locale}.yml")[locale])
  end

  def plugin_translations
    Hash(Plugins::Repository.translations_for(locale))
  end
end
