module CurrentUserHelper
  include PendingActionsHelper

  class SpamUserDeniedError < StandardError
  end

  def sign_in(user)
    @current_user = nil
    user = UserService.verify(user: user)
    super(user) && handle_pending_actions(user) && associate_user_to_visit
  end

  def current_user
    @current_user || super || LoggedOutUser.new(locale: logged_out_preferred_locale, params: params, session: session)
  end

  def deny_spam_users
    if ENV['SPAM_REGEX'] && Regexp.new(ENV['SPAM_REGEX']).match?(current_user.email)
      raise SpamUserDeniedError.new(current_user.email)
    end
  end

  private

  def associate_user_to_visit
    return unless current_visit

    if current_user.is_logged_in? and current_visit.user_id.nil?
      current_visit.update(user_id: current_user.id)
    end

    if params[:gclid] and current_visit.gclid.nil?
      current_visit.update(gclid: params[:gclid])
    end
  end

  def restricted_user
    User.find_by!(params.slice(:unsubscribe_token).permit!).tap { |user| user.restricted = true } if params[:unsubscribe_token]
  end

  def set_last_seen_at
    current_user.update_attribute :last_seen_at, Time.now
  end
end
