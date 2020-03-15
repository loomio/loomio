module ApiErrorRescueHelper
  def self.included(base)
    base.rescue_from(GroupInviter::InvitationLimitExceededError) do
      rescue_error('invitation_form.error.too_many_pending', count: ENV.fetch('MAX_PENDING_INVITATIONS', 100).to_i)
    end
  end

  def rescue_error(message, translation_values = {}, status = 400)
    render json: {errors: { emails: [I18n.t(message, translation_values)]}}, root: false, status: status
  end
end
