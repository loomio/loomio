class API::BootController < API::RestfulController
  def site
    render json: Boot::Site.new.payload.merge(user_payload)
  end

  def user
    flash[:notice] = "Outdated version detected! Loomio will not work! Hold shift key and press refresh button, or clear your cache to fix this."
    render json: user_payload
  end

  private
  def user_payload
    Boot::User.new(current_user,
                   identity: serialized_pending_identity,
                   flash: flash).payload
  end
  def current_user
    restricted_user || super
  end
end
