module AngularHelper

  def boot_angular_ui
    redirect_to :browser_not_supported and return if browser.ie? && browser.version.to_i < 10
    metadata                                      if browser.bot? && respond_to?(:metadata, true)
    app_config
    current_user.update(angular_ui_enabled: true) unless current_user.angular_ui_enabled?
    render 'layouts/angular', layout: false
  end

  def client_asset_path(filename)
    ['', :client, angular_asset_folder, filename].join('/')
  end

  private

  def app_config
    @appConfig = {
      bootData:            BootData.new(current_user, current_visitor).data,
      version:             Loomio::Version.current,
      environment:         Rails.env,
      loadVideos:          (ENV.has_key?('LOOMIO_LOAD_VIDEOS') or Rails.env.production?),
      flash:               flash.to_h,
      currentUserId:       current_user.id,
      currentVisitorId:    current_visitor.id,
      currentUserLocale:   current_user.locale,
      currentUrl:          request.original_url,
      canTranslate:        TranslationService.available?,
      permittedParams:     PermittedParamsSerializer.new({}),
      locales:             angular_locales,
      siteName:            ENV['SITE_NAME'] || 'Loomio',
      twitterHandle:       ENV['TWITTER_HANDLE'] || '@loomio',
      baseUrl:             root_url,
      safeThreadItemKinds: Discussion::THREAD_ITEM_KINDS,
      plugins:             Plugins::Repository.to_config,
      inlineTranslation: {
        isAvailable:       TranslationService.available?,
        supportedLangs:    Translation::SUPPORTED_LANGUAGES
      },
      pageSize: {
        default:           ENV['DEFAULT_PAGE_SIZE'] || 30,
        groupThreads:      ENV['GROUP_PAGE_SIZE'],
        threadItems:       ENV['THREAD_PAGE_SIZE'],
        exploreGroups:     ENV['EXPLORE_PAGE_SIZE'] || 10
      },
      flashTimeout: {
        short: (ENV['FLASH_TIMEOUT_SHORT'] || 3500).to_i,
        long:  (ENV['FLASH_TIMEOUT_LONG']  || 2147483645).to_i
      },
      drafts: {
        debounce: (ENV['LOOMIO_DRAFT_DEBOUNCE'] || 750).to_i
      },
      oauthProviders: [
        ({ name: :facebook, href: user_facebook_omniauth_authorize_path } if ENV['FACEBOOK_KEY']),
        ({ name: :twitter,  href: user_twitter_omniauth_authorize_path  } if ENV['TWITTER_KEY']),
        ({ name: :google,   href: user_google_omniauth_authorize_path   } if ENV['OMNI_CONTACTS_GOOGLE_KEY']),
        ({ name: :github,   href: user_github_omniauth_authorize_path   } if ENV['GITHUB_APP_ID'])
      ].compact,
      pollTemplates: Poll::TEMPLATES,
      pollColors:    Poll::COLORS,
      timeZones:     Poll::TIMEZONES
    }
  end

  def use_angular_ui?
    !request.xhr?
  end

  def angular_asset_folder
    Rails.env.production? ? Loomio::Version.current : :development
  end
end
