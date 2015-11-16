module AngularHelper
  def app_config
    @appConfig = {
      version: Loomio::Version.current,
      reportErrors: false,
      environment: Rails.env,
      flash: flash.to_h,
      currentUserId: current_user.id,
      currentUserLocale: current_user.locale,
      seedRecords: CurrentUserSerializer.new(current_user),
      permittedParams: PermittedParamsSerializer.new({}),
      locales: angular_locales,
      baseUrl: root_url,
      safeThreadItemKinds: Discussion::THREAD_ITEM_KINDS
    }

    if Rails.application.secrets.chargify_app_name
      @appConfig[:chargify] = {
        appName: Rails.application.secrets.chargify_app_name,
        host: "http://#{Rails.application.secrets.chargify_app_name}.chargify.com/",
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

  def boot_angular_ui
    if browser.ie? && browser.version.to_i < 10
      redirect_to :browser_not_supported and return
    end

    app_config

    render 'layouts/angular', layout: false
  end

  def use_angular_ui?
    current_user_or_visitor.angular_ui_enabled?
  end
end
