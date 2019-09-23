module CurrentUserHelper
  include PendingActionsHelper

  def sign_in(user)
    @current_user = nil
    user = UserService.verify(user: user)
    super(user) && handle_pending_actions(user)
  end

  def current_user
    @current_user || super || LoggedOutUser.new(locale: logged_out_preferred_locale)
  end

  private

  def restricted_user
    User.find_by!(params.slice(:unsubscribe_token).permit!).tap { |user| user.restricted = true } if params[:unsubscribe_token]
  end

  def set_last_seen_at
    current_user.update_attribute :last_seen_at, Time.now
  end
end
