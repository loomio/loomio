class API::V1::BootController < API::V1::RestfulController
  def site
    render json: Boot::Site.new.payload.merge(user_payload)
  end

  def user
    flash[:notice] = I18n.t(:'errors.clear_cache')
    render json: user_payload
  end

  private
  def user_payload
    Boot::User.new(current_user,
                   identity: serialized_pending_identity,
                   flash: flash,
                   channel_token: set_channel_token).payload
  end

  def set_channel_token
    token = SecureRandom.hex
    CHANNELS_REDIS_POOL.with do |client|
      client.set("/current_users/#{token}",
        {name: current_user.name,
         group_ids: current_user.group_ids,
         id: current_user.id}.to_json)
    end
    token
  end

  def current_user
    restricted_user || super
  end
end
