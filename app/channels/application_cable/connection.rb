module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      if (user = user_from_session_cookie)&.active_for_authentication?
        user
      else
        reject_unauthorized_connection
      end
    end

    def user_from_session_cookie
      Session.includes(:user).find_by(id: cookies.signed[:session_id])&.user if cookies.signed[:session_id]
    end
  end
end
