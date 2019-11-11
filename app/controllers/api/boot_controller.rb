class API::BootController < API::RestfulController
  def site
    render json: Boot::Site.new.payload
  end

  def user
    render json: Boot::User.new(current_user, identity: serialized_pending_identity, flash: flash).payload
  end

  private
  def current_user
    restricted_user || super
  end
end
