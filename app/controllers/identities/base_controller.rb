class Identities::BaseController < ApplicationController
  def oauth
    session[:back_to] = params[:back_to] || request.referrer
    redirect_to oauth_url
  end

  def create
    if !identity.valid?
      # TODO: this should be an error page, not JSON
      return render json: { error: "Could not connect to #{controller_name}!" }, status: :bad_request
    elsif existing_identity.presence
      existing_identity.update(access_token: identity.access_token)
      sign_in existing_identity.user
    elsif current_user.presence
      current_user.add_identity(identity)
    else
      session[:pending_identity_id] = identity.tap(&:save).id
    end
    redirect_to session.delete(:back_to) || dashboard_path
  end

  def destroy
    if current_user.send(:"#{controller_name}_identity")&.destroy
      redirect_to request.referrer || root_path
    else
      render json: { error: "Not connected to #{controller_name}!" }, status: :bad_request
    end
  end

  private

  def client
    @client ||= "Clients::#{controller_name.classify}".constantize.instance
  end

  def redirect_uri
    send :"#{controller_name}_authorize_url"
  end

  def identity
    @identity ||= identity_class.new(oauth_identity_params).tap { |i| complete_identity(i) }
  end

  def existing_identity
    @existing_identity ||= identity_class.with_user.find_by(
      identity_type: identity.identity_type,
      uid:           identity.uid
    )
  end

  # override with additional follow-up API calls if they're needed to gather more info
  # (such as logo url, user name, etc)
  def complete_identity(i)
    i.fetch_user_info
  end

  def identity_class
    "Identities::#{controller_name.classify}".constantize
  end

  def oauth_url
    "#{oauth_host}?#{oauth_params.to_query}"
  end

  def oauth_host
    raise NotImplementedError.new
  end

  def oauth_params
    raise NotImplementedError.new
  end

  def oauth_identity_params
    { access_token: client.fetch_access_token(params[:code], redirect_uri).json['access_token'] }
  end
end
