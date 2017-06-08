module AngularHelper
  include PendingActionsHelper
  EMOJIS = YAML.load_file(Rails.root.join("config", "emojis.yml")).as_json

  def boot_angular_ui
    metadata if browser.bot? && respond_to?(:metadata, true)
    app_config
    current_user.update(angular_ui_enabled: true) unless current_user.angular_ui_enabled?
    render 'layouts/angular', layout: false
  end

  def client_asset_path(filename)
    filename = filename.to_s.gsub(".min", '') if Rails.env.development?
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
      currentVisitorId:    current_visitor.id,
      currentUserLocale:   current_user.locale,
      currentUrl:          request.original_url,
      permittedParams:     PermittedParamsSerializer.new({}),
      locales:             angular_locales,
      siteName:            ENV.fetch('SITE_NAME', 'Loomio'),
      recaptchaKey:        ENV['RECAPTCHA_APP_KEY'],
      baseUrl:             root_url,
      safeThreadItemKinds: Discussion::THREAD_ITEM_KINDS,
      plugins:             Plugins::Repository.to_config,
      inlineTranslation: {
        isAvailable:       TranslationService.app_key.present?,
        supportedLangs:    TranslationService.supported_languages
      },
      pageSize: {
        default:           ENV.fetch('DEFAULT_PAGE_SIZE', 30),
        groupThreads:      ENV.fetch('GROUP_PAGE_SIZE',   30),
        threadItems:       ENV.fetch('THREAD_PAGE_SIZE',  30),
        exploreGroups:     ENV.fetch('EXPLORE_PAGE_SIZE', 10)
      },
      flashTimeout: {
        short: ENV.fetch('FLASH_TIMEOUT_SHORT', 3500).to_i,
        long:  ENV.fetch('FLASH_TIMEOUT_LONG', 2147483645).to_i
      },
      drafts: {
        debounce: ENV.fetch('LOOMIO_DRAFT_DEBOUNCE', 750).to_i
      },
      emojis: {
        defaults: EMOJIS.fetch('default', []).map { |e| ":#{e}:" }
      },
      searchFilters: { status: %w(active closed).freeze },
      pendingIdentity: serialized_pending_identity,
      pollTemplates: Poll::TEMPLATES,
      pollColors:    Poll::COLORS,
      timeZones:     Poll::TIMEZONES,
      communityProviders: Communities::Base::PROVIDERS,
      identityProviders: Identities::Base::PROVIDERS.map do |provider|
        ({ name: provider, href: send("#{provider}_oauth_path") } if ENV["#{provider.upcase}_APP_KEY"])
      end.compact
    }
  end

  def use_angular_ui?
    !request.xhr?
  end

  def angular_asset_folder
    Rails.env.production? ? Loomio::Version.current : :development
  end

  def serialized_pending_identity
    Pending::IdentitySerializer.new(pending_identity, root: false).as_json ||
    Pending::InvitationSerializer.new(pending_invitation, root: false).as_json ||
    Pending::UserSerializer.new(pending_user, root: false).as_json
  end
end
