class ClientTranslationService
  attr_reader :locale

  def initialize(locale)
    @locale = Loomio::I18n::FALLBACKS[locale].to_s
  end

  def to_json
    hash.to_json.html_safe
  end

  def hash
    @hash ||= base.deep_merge(core_translations).deep_merge(plugin_translations)
  end

  private

  def base
    if locale != I18n.locale.to_s
      self.class.new(I18n.locale.to_s).hash
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
