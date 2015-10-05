class BaseController < ApplicationController
  include AutodetectTimeZone
  include OmniauthAuthenticationHelper

  before_filter :authenticate_user!

  before_filter :check_for_omniauth_authentication,
                :check_for_invitation,
                :initialize_search_form,
                :ensure_user_name_present,
                :set_time_zone_from_javascript, unless: :ajax_request?

  before_filter :boot_angular_ui, if: :use_angular_ui?

  helper_method :time_zone
  #helper_method :permitted_params

  protected

  def boot_angular_ui
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

    render 'layouts/angular', layout: false
  end

  def use_angular_ui?
    current_user_or_visitor.angular_ui_enabled?
  end

  def ajax_request?
    request.xhr? or not user_signed_in?
  end

  def ensure_user_name_present
    unless current_user.name.present?
      redirect_to profile_path, alert: "Please enter your name to continue"
    end
  end

  def initialize_search_form
    @search_form = SearchForm.new(current_user)
  end

  def check_for_invitation
    if session[:invitation_token]
      redirect_to invitation_path(session[:invitation_token])
    end
  end
end
