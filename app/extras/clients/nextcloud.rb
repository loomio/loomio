class Clients::Nextcloud < Clients::Base

  def fetch_access_token(code, uri)
    post 'index.php/apps/oauth2/api/v1/token', params: { code: code, redirect_uri: uri, grant_type: :authorization_code }
  end

  def fetch_user_info
    get 'ocs/v2.php/cloud/user', params: { format: :json }
  end

  private

  def default_params
    { client_id: @key, client_secret: @secret }.delete_if { |k,v| v.nil? }
  end

  def authorization_headers
    { 'Authorization' => "Bearer #{@token}" }
  end

  def common_headers
    { 'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8' }
  end

  def default_headers
    if @token
      common_headers.merge(authorization_headers)
    else
      common_headers
    end
  end

  def default_host
    ENV['NEXTCLOUD_HOST']
  end
end
