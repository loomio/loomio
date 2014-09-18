class Users::UserDeactivationResponsesController < BaseController

  def create
    deactivation_response = UserDeactivationResponse.new(permitted_params.user_deactivation_response)
    deactivation_response.user = current_user
    deactivation_response.save
    current_user.deactivate!
    redirect_to root_url
  end
end
