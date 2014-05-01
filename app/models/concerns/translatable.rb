module Translatable
  # Requires base class to define:
  #   body

  extend ActiveSupport::Concern

  def translate(from_lang, to_lang)
    translator.translate(body, from: from_lang || detect_lang, to: to_lang) if can_translate? from_lang, to_lang
  end
  
  private
  
  def can_translate?(from, to)
    translator.present? && from != to
  end
  
  def translator
    @translator ||= BingTranslator.new get_env_or_fake('BING_TRANSLATE_APPID'), get_env_or_fake('BING_TRANSLATE_SECRET') rescue nil
  end
  
  def detect_lang
    translator.detect body
  end

  def get_env_or_fake(key)
    ENV[key] || ''
  end
  
end
