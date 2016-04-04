module AngularHelper

  def boot_angular_ui
    redirect_to :browser_not_supported and return if browser.ie? && browser.version.to_i < 10
    metadata                                      if browser.bot? && respond_to?(:metadata, true)
    app_config
    render 'layouts/angular', layout: false
  end

  def client_asset_path(filename)
    ['', :client, angular_asset_folder, filename].join('/')
  end

  private

  def app_config
    @appConfig = {
      version:             Loomio::Version.current,
      reportErrors:        false,
      environment:         Rails.env,
      loadVideos:          (ENV.has_key?('LOOMIO_LOAD_VIDEOS') or Rails.env.production?),
      flash:               flash.to_h,
      currentUserId:       current_user_or_visitor.id,
      currentUserLocale:   current_user_or_visitor.locale,
      currentUrl:          request.original_url,
      canTranslate:        TranslationService.available?,
      seedRecords:         CurrentUserSerializer.new(current_user_or_visitor),
      permittedParams:     PermittedParamsSerializer.new({}),
      locales:             angular_locales,
      siteName:            ENV['SITE_NAME'] || 'Loomio',
      twitterHandle:       ENV['TWITTER_HANDLE'] || '@loomio',
      baseUrl:             root_url,
      safeThreadItemKinds: Discussion::THREAD_ITEM_KINDS,
      plugins:             Plugins::Repository.to_config,
      chargify:            app_config_chargify,
      pageSize: {
        default:           ENV['DEFAULT_PAGE_SIZE'] || 30,
        groupThreads:      ENV['GROUP_PAGE_SIZE'],
        threadItems:       ENV['THREAD_PAGE_SIZE']
      }
    }
  end

  def app_config_chargify
    return unless Rails.application.secrets.chargify_app_name
    {
      appName: Rails.application.secrets.chargify_app_name,
      host: "https://#{Rails.application.secrets.chargify_app_name}.chargify.com/",
      plans: {
        standard: {
          name: Rails.application.secrets.chargify_standard_plan_name,
          path: "subscribe/#{Rails.application.secrets.chargify_standard_plan_key}/#{Rails.application.secrets.chargify_standard_plan_name}",
        },
        plus: {
          name: Rails.application.secrets.chargify_plus_plan_name,
          path: "subscribe/#{Rails.application.secrets.chargify_plus_plan_key}/#{Rails.application.secrets.chargify_plus_plan_name}"
        }
      },
      donation_url: Rails.application.secrets.chargify_donation_url,
      nagCache: {}
    }
  end

  def use_angular_ui?
    !request.xhr? && current_user_or_visitor.angular_ui_enabled?
  end

  def angular_asset_folder
    Rails.env.production? ? Loomio::Version.current : :development
  end
end
