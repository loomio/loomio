ModelLocator = Struct.new(:model, :params) do

  def locate
    return nil unless defined?(resource_class)
    if model.to_sym == :user
      resource_class.verified.find_by(username: params[:id] || params[:username]) || resource_class.friendly.find(params[:id] || params[:user_id])
    elsif model.to_sym == :group
      (model_key && resource_class.find_by(key: model_key)) ||
      (model_id && resource_class.find_by(id: model_id)) ||
      resource_class.where.not(handle: nil).find_by(handle: params[:id])
    elsif resource_class.respond_to?(:friendly)
      key_or_id = model_key ? model_key : model_id
      resource_class.friendly.find key_or_id
    else
      key_or_id = model_key ? model_key : model_id
      resource_class.find key_or_id
    end
  end

  def locate!
    locate or raise ActiveRecord::RecordNotFound
  end

  private

  def model_key
    # strip overloaded id's that chargify gives us in the form of
    # key-number
    (params[:"#{model}_key"] ||  params[:key]).to_s.split('-')[0]
  end

  def model_id
    (params[:"#{model}_id"] || params[:id]).to_s.split('-')[0]
  end

  def resource_class
    @resource_class ||= model.to_s.camelize.constantize
  end
end
