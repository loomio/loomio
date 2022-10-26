module Boot
  class Site
    include LocalesHelper
    include Routing

    def payload
      @payload ||= {
        version:             Loomio::Version.current,
        release:             AppConfig.release,
        systemNotice:        ENV['LOOMIO_SYSTEM_NOTICE'],
        environment:         Rails.env,
        permittedParams:     PermittedParamsSerializer.new({}),
        locales:             ActiveModel::ArraySerializer.new(supported_locales, each_serializer: LocaleSerializer, root: false),
        defaultLocale:       I18n.locale,
        momentLocales:       AppConfig.moment_locales,
        newsletterEnabled:   ENV['NEWSLETTER_ENABLED'],
        recaptchaKey:        ENV['RECAPTCHA_APP_KEY'],
        baseUrl:             root_url,
        contactEmail:        ENV['SUPPORT_EMAIL'],
        plugins:             { installed: [], outlets: [], routes: [] },
        theme:               AppConfig.theme,
        sentry_dsn:          ENV['SENTRY_PUBLIC_DSN'],
        plausible_src:       ENV['PLAUSIBLE_SRC'],
        plausible_site:      ENV['PLAUSIBLE_SITE'],
        features: {
          app:               AppConfig.app_features
        },
        inlineTranslation: {
          isAvailable:       TranslationService.available?,
          supportedLangs:    AppConfig.translate_languages
        },
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
