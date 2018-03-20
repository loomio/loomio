module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = user || invitation || reject_unauthorized_connection
    end

    private

    def user
      env['warden'].user
    end

    def invitation
      LoggedOutUser.new(token: request.params[:token]) if request.params[:token]
    end
  end
end
