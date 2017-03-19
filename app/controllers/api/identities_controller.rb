class API::IdentitiesController < API::RestfulController
  ACTION_NAMES = %w(channels admin_groups)

  def command
    current_participant.ability.authorize! :show, identity
    if valid_command?
      render json: identity.send(params[:command]), root: params[:command]
    else
      render json: { error: "#{params[:command]} is invalid for this identity" }, status: :bad_request
    end
  end

  private

  def valid_command?
    ACTION_NAMES.include?(params[:command]) && identity.respond_to?(params[:command])
  end

  def identity
    @identity ||= Identities::Base.find(params[:id])
  end
end
