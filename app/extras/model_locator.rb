ModelLocator = Struct.new(:model, :params) do

  def locate
    return nil unless defined?(resource_class)

    if model.to_sym == :user
      resource_class.verified.find_by(username: params[:id] || params[:username]) || resource_class.friendly.find(params[:id] || params[:user_id])
    elsif model.to_sym == :group
      (id_param && resource_class.find_by(id: id_param)) ||
      (key_param && resource_class.find_by(key: key_param)) ||
      resource_class.where.not(handle: nil).find_by(handle: params[:id])
    elsif resource_class.respond_to?(:friendly)
      resource_class.friendly.find key_or_id
    else
      resource_class.find key_or_id
    end
  end

  def locate!
    locate or raise ActiveRecord::RecordNotFound
  end

  private

  def id_param
    key_or_id.to_i.to_s == key_or_id && key_or_id
  end

  def key_param
    key_or_id.to_i.to_s != key_or_id && key_or_id
  end

  def key_or_id
    (params[:"#{model}_id"] || params[:"#{model}_key"] ||  params[:key] || params[:id]).to_s
  end

  def resource_class
    @resource_class ||= model.to_s.camelize.constantize
  end
end
