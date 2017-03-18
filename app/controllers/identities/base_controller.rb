class Identities::BaseController < ApplicationController
  def oauth
    session[:back_to] = request.referrer
    redirect_to "#{oauth_url}?#{oauth_params.to_query}"
  end

  def create
    if current_user.identities.push build_identity
      redirect_to session.delete(:back_to) || root_path
    else
      render json: { error: "Could not connect to #{controller_name}!" }, status: :bad_request
    end
  end

  def destroy
    if identity.present?
      identity.destroy
      redirect_to request.referrer
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
    raise NotImplementedError.new
  end

  def build_identity
    raise NotImplementedError.new
  end

  def oauth_url
    raise NotImplementedError.new
  end

  def oauth_params
    { redirect_uri: redirect_uri }
  end
end
