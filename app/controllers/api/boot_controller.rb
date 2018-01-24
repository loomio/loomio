class API::BootController < API::RestfulController
  def site
    render json: InitialPayload.new.payload
  end

  def user
    render json: BootData.new(current_user, identity: serialized_pending_identity, flash: flash).payload
  end
end
