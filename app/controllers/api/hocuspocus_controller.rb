class Api::HocuspocusController < ActionController::Base
  skip_before_action :verify_authenticity_token

  RECORD_TYPES = %w[comment discussion poll stance outcome pollTemplate discussionTemplate group user]

  def create
    user_id, secret_token = params[:user_secret].split(',')
    record_type, record_id, user_id_if_new = params[:document_name].split('-')
    raise "invalid record type #{record_type}" unless RECORD_TYPES.include?(record_type)

    if user_id == '0'
      if record_type == 'group' && record_id == 'new'
        head :ok
      else
        head :unauthorized
      end
      return
    end

    u = User.active.find_by!(id: user_id)

    logger.debug({
      hocuspocus: 'debugme',
      params_user_secret: params[:user_secret],
      params_user_id: user_id,
      params_secret_token: secret_token,
      user_id: u.id,
      user_name: u.name,
      user_email: u.email,
      user_secret_token: u.secret_token
    })

    user = User.active.find_by!(id: user_id, secret_token: secret_token)

    if record_id == 'new'
      if user_id_if_new.to_i == user.id
        head :ok
      else
        head :unauthorized
      end
    else
      logger.debug({
        hocuspocus: 'debugme',
        record_type: record_type,
        record_id: record_id,
        user_can_update: user.can?(:update, record_type.camelize.constantize.find(record_id.to_i))
      })
      if user.can? :update, record_type.camelize.constantize.find(record_id.to_i)
        head :ok
      else
        head :unauthorized
      end
    end
  rescue ActiveRecord::RecordNotFound => e
    logger.debug("hocuspocus controller rescued ActiveRecord::RecordNotFound #{e.inspect}")
    head :unauthorized
  end
end
