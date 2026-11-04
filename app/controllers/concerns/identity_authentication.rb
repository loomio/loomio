module IdentityAuthentication
  private

  # Completes the shared account and session work after an OAuth or SAML
  # provider response has been independently validated.
  def finish_identity_authentication(identity)
    return stage_identity_switch(identity) unless identity.user

    if identity.user.incomplete?
      stage_account_completion(identity.user, name_managed: identity.name.present?)
      session[:pending_user_id] = identity.user.id
    else
      sign_in(identity.user)
      flash[:notice] = t('auth_form.signed_in')
    end

    redirect_to authentication_return_path(fallback: dashboard_path)
  end

  def stage_identity_switch(identity)
    back_to = session[:back_to]
    sign_out
    session[:pending_identity_id] = identity.id

    flash[:notice] = t('auth.switching_accounts')
    redirect_to session.delete(:return_to_after_authenticating) || back_to || dashboard_path
  end

  def disconnect_identity(identity_type, label: identity_type)
    identity = current_user.identities.find_by(identity_type: identity_type)
    return respond_with_error(500, "Not connected to #{label}!") unless identity

    identity.destroy
    redirect_to request.referrer || root_path
  end
end
