module RequiresLocalLogin
  extend ActiveSupport::Concern

  included do
    before_action :require_local_login
  end

  private

  def require_local_login
    return if AppConfig.local_login_enabled?

    render json: { error: I18n.t('auth_form.local_login_disabled') }, status: :forbidden
  end
end
