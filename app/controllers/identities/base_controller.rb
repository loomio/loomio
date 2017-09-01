class Identities::BaseController < ApplicationController
  def oauth
    session[:back_to] = params[:back_to] || request.referrer
    redirect_to oauth_url
  end

  def create
    if identity.save
      associate_identity
      redirect_to session.delete(:back_to) || dashboard_path
    else
      respond_with_error message: "Could not connect to #{controller_name}!"
    end
  end

  def destroy
    if i = current_user.identities.find_by(identity_type: controller_name)
      i.destroy
      redirect_to request.referrer || root_path
    else
      respond_with_error message: "Not connected to #{controller_name}!"
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
    @identity ||= identity_class.new(identity_params).tap { |i| complete_identity(i) }
  end

  def existing_identity
    @existing_identity ||= identity_class.with_user.find_by(
      identity_type: identity.identity_type,
      uid:           identity.uid
    )
  end

  def existing_user
    @existing_user ||= User.verified.find_by(email: identity.email)
  end

  def associate_identity
    if user = existing_identity&.user || current_user.presence || existing_user
      user.associate_with_identity(identity)
      sign_in(user)
      flash[:notice] = t(:'devise.sessions.signed_in')
    else
      session[:pending_identity_id] = identity.tap(&:save).id
    end
  end

  # override with differing ways to fetch the access token from the response
  def identity_params
    { access_token: client.fetch_access_token(params[:code], redirect_uri).json['access_token'] }
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
    { client.client_key_name => client.key, redirect_uri: redirect_uri, scope: oauth_scope }
  end

  def oauth_client_id_field
    :client_id
  end

  def oauth_scope
    client.scope.join(',')
  end
end
