module PunditAuthorization
  extend ActiveSupport::Concern

  include Pundit::Authorization

  included do
    class_attribute :pundit_authorization_modes, instance_writer: false, default: {}
    after_action :verify_declared_pundit_authorization
  end

  class_methods do
    def pundit_authorization_mode(mode, only:)
      actions = Array(only).map(&:to_s)
      self.pundit_authorization_modes = pundit_authorization_modes.merge(
        actions.to_h { |action| [action, mode.to_sym] }
      )
    end
  end

  private

  def authorize_public_response!(name, reason:)
    raise ArgumentError, "public authorization requires a reason" if reason.blank?

    authorize(name, :show?, policy_class: PublicResponsePolicy)
    @pundit_response_authorization = {
      mode: :public,
      name: name.to_sym,
      reason: reason
    }
  end

  def pundit_user
    @pundit_user ||= AuthorizationContext.new(
      user: current_user,
      authentication: pundit_authentication
    )
  end

  def pundit_authentication
    return :b2_api_key if controller_path.start_with?("api/b2/")
    return :b3_api_key if controller_path.start_with?("api/b3/")
    return :unsubscribe_token if current_user.respond_to?(:restricted) && current_user.restricted
    return :session if Current.session&.user_id == current_user.id
    return :topic_reader_token if current_user.topic_reader_token.present?

    :signed_out
  end

  def verify_declared_pundit_authorization
    mode = pundit_authorization_modes[action_name]
    return unless mode

    evidence = @pundit_response_authorization
    if evidence.nil?
      raise Pundit::AuthorizationNotPerformedError,
            "#{controller_path}##{action_name} rendered without response authorization"
    end
    return if evidence[:mode] == mode

    raise Pundit::AuthorizationNotPerformedError,
          "#{controller_path}##{action_name} declared #{mode}, recorded #{evidence[:mode]}"
  end
end
