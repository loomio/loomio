module GroupsHelper
  def display_subgroups_block?(group)
    group.parent.nil? && (group.subgroups.present? || (current_user && group.users_include?(current_user)))
  end

  def input_error_class(model_name)
    if model_name == "group"
      'inputError limit-250'
    end
  end
end
