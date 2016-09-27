module FetchAndAuthorize

  def fetch_and_authorize_resource
    fetch_and_authorize resource_symbol, action_name.to_sym
  end

  def fetch_and_authorize(model, action = :show, optional: false)
    return if optional && !(params[:"#{model}_id"] || params[:"#{model}_key"])
    authorize! action, fetch_resource(model)
  end

  def fetch_resource(model = resource_symbol)
    instance_variable_set :"@#{model}", ModelLocator.new(model, params).locate
  end
end
