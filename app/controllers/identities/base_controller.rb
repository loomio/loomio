class Identities::BaseController < ApplicationController
  def oauth
    session[:back_to] = params[:back_to] || request.referrer
    redirect_to "#{oauth_url}?#{oauth_params.to_query}"
  end

  def create
    if created_identity.persisted?
      store_identity
      redirect_to session.delete(:back_to) || dashboard_path
    else
      # TODO: this should be an error page, not JSON
      render json: { error: "Could not connect to #{controller_name}!" }, status: :bad_request
    end
  end

  def destroy
    if identity.present?
      identity.destroy
      redirect_to request.referrer || root_path
    else
      render json: { error: "Not connected to #{controller_name}!" }, status: :bad_request
    end
  end

  private

  def respond_with_bad_request
    render json: { error: "Could not connect to #{controller_name}!" }, status: :bad_request
  end

  def client
    @client ||= "Clients::#{controller_name.classify}".constantize.instance
  end

  def redirect_uri
    send :"#{controller_name}_authorize_url"
  end

  def identity
    current_user.send "#{controller_name}_identity"
  end

  def created_identity
    @created_identity ||= instantiate_identity.tap { |identity| complete_identity(identity) }.tap(&:save)
  end

  def instantiate_identity
    "Identities::#{controller_name.classify}".constantize.new(oauth_identity_params)
  end

  def store_identity
    if identity_user.is_logged_in?
      identity_user.identities.push(created_identity)
    else
      session[:pending_identity_id] = created_identity.id
    end
  end

  def identity_user
    @identity_user ||= User.find_by_email(created_identity.email) || current_user
  end

  def complete_identity(identity)
    # override me with follow-up API calls if they're needed to gather more info
    # (such as logo url, user name, etc)
  end

  def oauth_url
    raise NotImplementedError.new
  end

  def oauth_identity_params
    { access_token: client.fetch_oauth(params[:code], redirect_uri).json['access_token'] }
  end

  def oauth_params
    { redirect_uri: redirect_uri, scope: client.scope.join(',') }
  end
end
