module LoadAndAuthorize
  def load_and_authorize(model, action = :show, optional: false)
    # GK: TODO: announcements_controller's notified_group method assumes this is a :group, but it could also be a poll or discussion
    return if optional && !(params[:"#{model}_id"] || params[:"#{model}_key"])
    instance_variable_set :"@#{model}", ModelLocator.new(model, params).locate
    current_user.ability.authorize! action, instance_variable_get(:"@#{model}")
  end
end
