module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = cookies.encrypted[:_session_id] && request.session[:session_token]
      user = token && Session.find_by(token: token)&.user
      user || reject_unauthorized_connection
    end
  end
end
