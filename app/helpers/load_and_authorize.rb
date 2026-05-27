module LoadAndAuthorize
  def load_and_authorize(name, action = :show, optional: false)
    return if optional && !(params[:"#{name}_id"] || params[:"#{name}_key"])
    resource = ModelLocator.new(name, params).locate!
    current_user.ability.authorize! action, resource
    instance_variable_set :"@#{name}", resource
    resource
  end
end
