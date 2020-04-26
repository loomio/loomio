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

        # these can be deleted after angular is really really gone
        flashTimeout:        { long: 9999999, short: 999999 },
        pageSize:            { default: 10, groupThreads: 10, threadItems: 10, exploreGroups: 10 },
        drafts:              { debounce: 1000},
        searchFilters:       { status: %w(active closed) },
        emojis:              { defaults:  [] },
        # these can be deleted after angular is really really gone

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
