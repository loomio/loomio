class Api::V1::BootController < Api::V1::RestfulController
  def site
    set_channel_token
    render json: Boot::Site.new.payload.merge(user_payload)
    EventBus.broadcast('boot_site', current_user)
  end

  def version
    render json: {
      version: Version.current,
      release: AppConfig.release,
      reload: (params.fetch(:version, '0.0.0') < Version.current) ||
              (ENV['LOOMIO_SYSTEM_RELOAD'] && AppConfig.release != params[:release]),
      notice: ENV['LOOMIO_SYSTEM_NOTICE']
    }
  end

  private
  def user_payload
    Boot::User.new(current_user,
                   root_url: URI(root_url).origin,
                   identity: serialized_pending_identity,
                   flash: flash).payload
  end

  def set_channel_token
    CACHE_REDIS_POOL.with do |client|
      client.set("/current_users/#{current_user.secret_token}",
        {name: current_user.name,
         group_ids: current_user.group_ids,
         id: current_user.id}.to_json)
    end
  end

  def current_user
    restricted_user || super
  end
end
