class Api::HocuspocusController < ActionController::Base
  skip_before_action :verify_authenticity_token

  RECORD_TYPES = %w[comment discussion poll stance outcome pollTemplate discussionTemplate group user]

  def create
    user_id, secret_token = params[:user_secret].split(',')

    if user_id == '0'
      head :ok
      return
    end

    user = User.active.find_by!(id: user_id, secret_token: secret_token)

    record_type, record_id, user_id_if_new = params[:document_name].split('-')

    raise "invalid record type #{record_type}" unless RECORD_TYPES.include?(record_type)

    if record_id == 'new'
      if user_id_if_new.to_i == user.id
        head :ok
      else
        head :unauthorized
      end
    else
      if user.can? :update, record_type.camelize.constantize.find(record_id.to_i)
        head :ok
      else
        head :unauthorized
      end
    end
  rescue ActiveRecord::RecordNotFound
    head :unauthorized
  end
end
