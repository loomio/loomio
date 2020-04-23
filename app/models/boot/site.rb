module Boot
  class Site
    include LocalesHelper
    include Routing

    def payload
      @payload ||= {
        version:             Loomio::Version.current,
        environment:         Rails.env,
        permittedParams:     PermittedParamsSerializer.new({}),
        locales:             ActiveModel::ArraySerializer.new(supported_locales, each_serializer: LocaleSerializer, root: false),
        defaultLocale:       I18n.locale,
        momentLocales:       AppConfig.moment_locales,
        newsletterEnabled:   ENV['NEWSLETTER_ENABLED'],
        recaptchaKey:        ENV['RECAPTCHA_APP_KEY'],
        baseUrl:             root_url,
        contactEmail:        ENV['SUPPORT_EMAIL'],
        theme:               AppConfig.theme,
        sentry_dsn:          ENV['SENTRY_PUBLIC_DSN'],
        features: {
          app:               AppConfig.app_features
        },
        inlineTranslation: {
          isAvailable:       TranslationService.translator.present?,
          supportedLangs:    AppConfig.translate_languages
        },
        pollTemplates:     AppConfig.poll_templates,
        pollTypes:         AppConfig.poll_types,
        pollColors:        AppConfig.colors,
        webhookEventKinds: AppConfig.webhook_event_kinds,
        identityProviders: AppConfig.providers.fetch('identity', []).map do |provider|
          ({ name: provider, href: send("#{provider}_oauth_path") } if ENV["#{provider.upcase}_APP_KEY"])
        end.compact
      }
    end
  end
end
