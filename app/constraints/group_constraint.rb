class GroupConstraint

  def matches?(request)
    request_method = request.env['REQUEST_METHOD']
    action         = request.path_parameters[:action]

    case request_method
      when 'GET'
        %w[ add_subgroup members_autocomplete edit ].include? action
      when 'POST'
        %w[ add_members hide_next_steps edit_description email_members archive ].include? action
      when 'PUT'
        %w[  ].include? action
      when 'DELETE'
        %w[ ].include? action
      else
        false
    end
  end

end
