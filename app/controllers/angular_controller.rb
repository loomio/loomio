class AngularController < ApplicationController
  include AngularHelper
  before_filter :authenticate_user!
  before_filter :app_config, only: :boot
  layout 'pages'
  layout false, only: :boot

  def toggle
    @enabled = current_user_or_visitor.angular_ui_enabled?
    @mode    = @enabled ? 'disable' : 'enable'
  end

  def boot
  end

  def on
    current_user.update_attribute :angular_ui_enabled, true
    redirect_to '/'
  end

  def off
    current_user.update_attribute :angular_ui_enabled, false
    redirect_to '/'
  end

  private

  def app_config
    @appConfig = {
      hostedByLoomio: ENV['HOSTED_BY_LOOMIO'],
      version: Loomio::Version.current,
      reportErrors: false,
      environment: Rails.env,
      loadVideos: (ENV.has_key?('LOOMIO_LOAD_VIDEOS') or Rails.env.production?),
      flash: flash.to_h,
      currentUserId: current_user_or_visitor.id,
      currentUserLocale: current_user_or_visitor.locale,
      canTranslate: TranslationService.available?,
      seedRecords: CurrentUserSerializer.new(current_user_or_visitor),
      permittedParams: PermittedParamsSerializer.new({}),
      locales: angular_locales,
      baseUrl: root_url,
      safeThreadItemKinds: Discussion::THREAD_ITEM_KINDS,
      intercomAppId: Rails.application.secrets.intercom_app_id,
      intercomUserHash: Digest::SHA1.hexdigest("#{Rails.application.secrets.intercom_app_secret}#{current_user_or_visitor.id}"),
      plugins: Plugins::Repository.to_config,
      chargify: app_config_chargify
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
end
