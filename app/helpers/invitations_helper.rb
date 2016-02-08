module InvitationsHelper
  def clear_invitation_token_from_session
    session[:invitation_token] = nil
  end

  def save_invitation_token_to_session
    session[:invitation_token] = params[:id]
  end

  def invitation_token_in_session?
    session.has_key?(:invitation_token)
  end

  def load_invitation_from_session
    if session[:invitation_token]
      @invitation = Invitation.pending.find_by_token(session[:invitation_token])
    end
  end

  def login_or_signup_path_for_email(email)
    if email.blank? or not User.email_taken?(email)
      new_user_registration_path
    else
      new_user_session_path(email: email)
    end
  end
end
