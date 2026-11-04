class Api::V1::BootController < Api::V1::RestfulController
  def site
    Sentry.metrics.count("boot.site", attributes: { signed_in: current_user.is_logged_in? })
    render json: Boot::Site.new.payload.merge(user_payload)
  end

  def version
    client_version = params.fetch(:version, '0.0.0')
    return head :bad_request unless client_version.is_a?(String) && client_version.present? && Gem::Version.correct?(client_version)

    render json: {
      version: Version.current,
      release: AppConfig.release,
      reload: (Gem::Version.new(client_version) < Gem::Version.new(Version.current)) ||
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

end
