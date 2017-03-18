module LoadAndAuthorize
  def load_and_authorize(model, action = :show, optional: false)
    return if optional && !(params[:"#{model}_id"] || params[:"#{model}_key"])
    instance_variable_set :"@#{model}", ModelLocator.new(model, params).locate
    current_participant.ability.authorize! action, instance_variable_get(:"@#{model}")
  end
end
