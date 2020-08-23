class API::BootController < API::RestfulController
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
    redis_url = ENV['REDIS_QUEUE_URL'] || ENV.fetch('REDIS_URL', 'redis://localhost:6379')
    redis = Redis.new(url: redis_url)
    token = SecureRandom.hex
    redis.set("/current_users/#{token}",
      {name: current_user.name,
       group_ids: current_user.group_ids,
       # guest_discussion_ids: current_user.guest_discussion_ids,
       user_id: current_user.id}.to_json)
    token
  end

  def current_user
    restricted_user || super
  end
end
