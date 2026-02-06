module TranslationProviders
  class ProviderManager
    def initialize
      @providers = configured_providers
      @exhausted_providers = {}
    end

    def next_available_provider
      @providers.find { |provider| !provider_exhausted?(provider) }
    end

    def mark_provider_exhausted(provider)
      @exhausted_providers[provider.class.provider_name] = Date.current.to_s
      Rails.logger.warn "#{provider.class.name} quota exhausted for #{Date.current}"
    end

    def provider_exhausted?(provider)
      @exhausted_providers[provider.class.provider_name] == Date.current.to_s
    end

    private

    def configured_providers
      provider_names = ENV['TRANSLATION_PROVIDERS']&.split(',')&.map(&:strip) || %w[google azure]

      provider_names.map do |name|
        klass = "TranslationProviders::#{name.classify}".constantize
        klass.new if klass.available?
      rescue NameError
        Rails.logger.warn "Unknown translation provider: #{name}"
        nil
      end.compact
    end
  end
end
