InitialPayload = Struct.new(:user) do
  include LocalesHelper
  include Routing

  def payload
    @payload ||= {
      bootData:            BootData.new(user).data,
      version:             Loomio::Version.current,
      environment:         Rails.env,
      loadVideos:          ENV['LOOMIO_LOAD_VIDEOS'],
      currentUserLocale:   user.locale,
      permittedParams:     PermittedParamsSerializer.new({}),
      locales:             angular_locales,
      recaptchaKey:        ENV['RECAPTCHA_APP_KEY'],
      baseUrl:             root_url,
      safeThreadItemKinds: Discussion::THREAD_ITEM_KINDS,
      plugins:             Plugins::Repository.to_config,
      inlineTranslation: {
        isAvailable:       TranslationService.app_key.present?,
        supportedLangs:    TranslationService.supported_languages
      },
      pageSize: {
        default:         ENV.fetch('DEFAULT_PAGE_SIZE', 30),
        groupThreads:    ENV.fetch('GROUP_PAGE_SIZE',   30),
        threadItems:     ENV.fetch('THREAD_PAGE_SIZE',  30),
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
      pollColors:        AppConfig.colors,
      timeZones:         AppConfig.timezones,
      identityProviders: AppConfig.providers.fetch('identity', []).map do |provider|
        ({ name: provider, href: send("#{provider}_oauth_path") } if ENV["#{provider.upcase}_APP_KEY"])
      end.compact,
      intercom: {
        appId: Rails.application.secrets.intercom_app_id,
        userHash: Digest::SHA1.hexdigest("#{Rails.application.secrets.intercom_app_secret}#{user.id}")
      }.compact
    }
  end
end
