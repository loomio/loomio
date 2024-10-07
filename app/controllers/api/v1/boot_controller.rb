class API::V1::BootController < API::V1::RestfulController
  def site
    render json: Boot::Site.new.payload.merge(user_payload)
    EventBus.broadcast('boot_site', current_user)
  end

  def version
    render json: {
      version: Loomio::Version.current,
      release: AppConfig.release,
      reload: (params.fetch(:version, '0.0.0') < Loomio::Version.current) ||
              (ENV['LOOMIO_SYSTEM_RELOAD'] && AppConfig.release != params[:release]),
      notice: ENV['LOOMIO_SYSTEM_NOTICE']
    }
  end

  private
  def user_payload
    Boot::User.new(current_user,
                   identity: serialized_pending_identity,
                   flash: flash,
                   channel_token: set_channel_token).payload
  end

  def set_channel_token
    token = current_user.secret_token || SecureRandom.hex
    CACHE_REDIS_POOL.with do |client|
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
