class PersonaValidator
  VERIFICATION_HOST = 'https://verifier.login.persona.org'

  def initialize(assertion, audience)
    @assertion = assertion
    @audience = audience
  end

  def valid?
    return false unless @assertion

    http = Net::HTTP.new(VERIFICATION_HOST, 443)
    http.use_ssl = true

    verification_request = Net::HTTP::Post.new('/verify')
    verification_request.set_form_data({:assertion => @assertion,
                                        :audience => @audience})

    response = http.request(verification_request)
    @asserted = JSON.parse(response.body)

    (@asserted['status'] == 'okay') and (@asserted['audience'] == @audience)
  end

  def email
    @asserted['email']
  end
end
