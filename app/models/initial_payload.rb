InitialPayload = Struct.new(:user) do
  include LocalesHelper
  include Routing
  include AngularHelper

  def payload
    @payload ||= {
      bootData:            BootData.new(user).data,
      version:             Loomio::Version.current,
      assetRoot:           angular_asset_folder,
      environment:         Rails.env,
      loadVideos:          ENV['LOOMIO_LOAD_VIDEOS'],
      currentUserLocale:   user.locale,
      permittedParams:     PermittedParamsSerializer.new({}),
      locales:             ActiveModel::ArraySerializer.new(supported_locales, each_serializer: LocaleSerializer, root: false),
      recaptchaKey:        ENV['RECAPTCHA_APP_KEY'],
      baseUrl:             root_url,
      plugins:             Plugins::Repository.to_config,
      theme:               AppConfig.theme,
      errbit:              AppConfig.errbit,
      regex: {
        url:               JsRegex.new(AppConfig::URL_REGEX),
        email:             JsRegex.new(AppConfig::EMAIL_REGEX)
      },
      features: {
        group:             AppConfig.group_features,
        app:               AppConfig.app_features
      },
      inlineTranslation: {
        isAvailable:       TranslationService.supported_languages.any?,
        supportedLangs:    TranslationService.supported_languages
      },
      pageSize: {
        default:         ENV.fetch('DEFAULT_PAGE_SIZE', 30),
        groupThreads:    ENV.fetch('GROUP_PAGE_SIZE',   30),
        threadItems:     ENV.fetch('THREAD_PAGE_SIZE',  10),
        exploreGroups:   ENV.fetch('EXPLORE_PAGE_SIZE', 10)
      },
      flashTimeout: {
        short:           ENV.fetch('FLASH_TIMEOUT_SHORT', 3500).to_i,
        long:            ENV.fetch('FLASH_TIMEOUT_LONG', 2147483645).to_i
      },
      drafts: {
        debounce:        ENV.fetch('LOOMIO_DRAFT_DEBOUNCE', 750).to_i
      },
      searchFilters: {
        status: %w(active closed).freeze
      },
      emojis: {
        defaults:        AppConfig.emojis.fetch('default', []).map { |e| ":#{e}:" }
      },
      notifications: {
        kinds:           AppConfig.notifications.fetch('kinds', [])
      },
      durations:         AppConfig.durations.fetch('durations', []),
      pollTemplates:     AppConfig.poll_templates,
      pollTypes:         AppConfig.poll_types,
      pollColors:        AppConfig.colors,
      timeZones:         AppConfig.timezones,
      identityProviders: AppConfig.providers.fetch('identity', []).map do |provider|
        ({ name: provider, href: send("#{provider}_oauth_path") } if ENV["#{provider.upcase}_APP_KEY"])
      end.compact,
      intercom: {
        appId: Rails.application.secrets.intercom_app_id,
        userHash: (OpenSSL::HMAC.hexdigest(
          'sha256',
          Rails.application.secrets.intercom_app_secret,
          user.id.to_s
        ) if Rails.application.secrets.intercom_app_secret)
      }.compact
    }
  end
end
