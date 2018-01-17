ModelLocator = Struct.new(:model, :params) do

  def locate
    if model.to_sym == :user
      resource_class.find_by(username: params[:id] || params[:username]) || resource_class.friendly.find(params[:id])
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
    (params[:"#{model}_id"] || params[:"#{model}_key"] ||  params[:key] || params[:id]).to_s.split('-')[0]
  end

  def resource_class
    @resource_class ||= model.to_s.camelize.constantize
  end
end
