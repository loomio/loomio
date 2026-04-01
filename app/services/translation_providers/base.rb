module TranslationProviders
  class Base
    def translate(content, to:, format: :text)
      raise NotImplementedError
    end

    def self.available?
      raise NotImplementedError
    end

    def supported_languages
      []
    end
  end
end
