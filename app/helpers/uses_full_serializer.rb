module UsesFullSerializer
  def resource_serializer
    if full_controller_actions.include? action_name
      "Full::#{controller_name.singularize.camelize}Serializer".constantize
    else
      super
    end
  end

  def full_controller_actions
    ['show']
  end
end
