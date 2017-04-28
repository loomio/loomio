class Identities::BaseController < ApplicationController
  def oauth
    session[:back_to] = params[:back_to] || request.referrer
    redirect_to "#{oauth_url}?#{oauth_params.to_query}"
  end

  def create
    if associate(user: current_user, identity: instantiate_identity)
      redirect_to session.delete(:back_to) || root_path
    else
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

  def client
    @client ||= "Clients::#{controller_name.classify}".constantize.new(
      key:    ENV["#{controller_name.classify.upcase}_APP_KEY"],
      secret: ENV["#{controller_name.classify.upcase}_APP_SECRET"]
    )
  end

  def redirect_uri
    send :"#{controller_name}_authorize_url"
  end

  def identity
    current_user.send "#{controller_name}_identity"
  end

  def associate(user:, identity:)
    if user.is_logged_in?
      user.identities.push(identity)
    else
      User.new(email: identity.email, identities: Array(identity)).save
    end
  end

  def instantiate_identity
    "Identities::#{controller_name.classify}".constantize.new(oauth_identity_params).tap do |identity|
      complete_identity(identity)
    end
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
    { redirect_uri: redirect_uri }
  end
end
