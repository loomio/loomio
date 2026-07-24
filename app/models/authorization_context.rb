class AuthorizationContext
  attr_reader :user, :authentication, :operator

  delegate_missing_to :user

  def initialize(user:, authentication:, operator: nil)
    @user = user
    @authentication = authentication.to_sym
    @operator = operator
  end

  def signed_out?
    authentication == :signed_out
  end

  def api_key?
    %i[b2_api_key b3_api_key].include?(authentication)
  end
end
