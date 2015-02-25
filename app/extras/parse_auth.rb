class ParseAuth
  include HTTParty

  headers({'X-Parse-Application-Id' => ENV['PARSE_ID'],
           'X-Parse-REST-API-Key' => ENV['PARSE_KEY'],
           'Content-Type' => 'application/json'})

  base_uri 'https://api.parse.com/1/functions'

  def self.login_with_email_and_password(email, password)
    handle_response self.post('/authenticateUser',
                              body: {username: email, password: password}.to_json)

  end

  def self.get_user_details(email)
    handle_response self.post('/getUserDetails',
                              body: {username: email}.to_json)
  end

  def self.handle_response(response)
    if response.code == 200
      response['result']
    else
      false
    end
  end
end
