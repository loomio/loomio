class API::BootController < API::RestfulController
  def site
    render json: Boot::Payload::Site.new.payload
  end

  def user
    render json: Boot::Payload::User.new(current_user, identity: serialized_pending_identity, flash: flash).payload
  end
end
