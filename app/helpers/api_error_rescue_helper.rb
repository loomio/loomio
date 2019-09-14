module ApiErrorRescueHelper
  def self.included(base)
    base.rescue_from(GroupInviter::InvitationLimitExceededError) do
      count = ENV.fetch('MAX_PENDING_INVITATIONS', 100).to_i
      rescue_error(400, { emails: [I18n.t('invitation_form.error.too_many_pending', count: count)] })
    end

    base.rescue_from(Identities::Saml::AuthenticationRequiredError) do
      rescue_error(401, { idp: resource.saml_identity.saml_url, provider: :saml })
    end
  end

  def rescue_error(status = 400, errors = {})
    render json: { errors: errors }, root: false, status: status
  end
end
