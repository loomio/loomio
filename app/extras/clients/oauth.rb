class Clients::Oauth < Clients::Base

  def fetch_access_token(code, uri)
    post ENV.fetch('OAUTH_TOKEN_URL'), params: { code: code, redirect_uri: uri, grant_type: :authorization_code }
  end

  def fetch_user_info
    get ENV.fetch('OAUTH_PROFILE_URL')
  end

  private
  def perform(method, url, params, headers, options)
    options.reverse_merge!(
      success:    default_success,
      failure:    default_failure,
      is_success: default_is_success
    )
    Clients::Request.new(method, url, {
      options[:params_field] => params_for(params),
      :"headers"             => headers_for(headers)
    }).tap { |request| request.perform!(options) }
  end


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
end
