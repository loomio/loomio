class GroupConstraint
  def self.matches?(request)

    request_method = request.env['REQUEST_METHOD']
    action         = request.path_parameters[:action]

    case request_method
      when 'GET'
        %w[ add_subgroup members_autocomplete edit ].include? action
      when 'POST'
        t = %w[ add_members hide_next_steps email_members edit_description archive ].include? action
        puts t
        false
      when 'PUT'
        %w[  ].include? action
      when 'DELETE'
        %w[ ].include? action
      else
        false
    end
  end
end
