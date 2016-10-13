ModelLocator = Struct.new(:model, :params) do

  def locate
    if id_param = params[:"#{model}_id"]
      resource_class.find id_param
    elsif key_param = params[:"#{model}_key"]
      resource_class.find_by_key key_param
    elsif model.to_sym == :user
      resource_class.find_by(username: params[:id] || params[:username]) || resource_class.find(params[:id])
    elsif resource_class.respond_to?(:friendly)
      resource_class.friendly.find key_or_id
    else
      resource_class.find key_or_id
    end
  end

  private

  def key_or_id
    # strip overloaded id's that chargify gives us in the form of
    # key-number
    (params[:key] || params[:id]).to_s.split('-')[0]
  end

  def resource_class
    @resource_class ||= model.to_s.camelize.constantize
  end
end
