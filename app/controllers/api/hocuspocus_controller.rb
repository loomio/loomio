class API::HocuspocusController < ActionController::Base
  skip_before_action :verify_authenticity_token

  TYPES = %w[comment discussion poll stance outcome pollTemplate discussionTemplate group user]

  def create
    id, secret_token = params[:user_secret].split(',')
    user = User.active.find_by!(id: id, secret_token: secret_token)

    type, id = params[:document_name].split('-')
    raise "invalid record type #{type}" unless TYPES.include?(type)

    if id == 'new'
      head :ok
    else
      if user.can? :update, type.camelize.constantize.find(id.to_i)
        head :ok
      else
        head :unauthorized
      end
    end
  end
end
