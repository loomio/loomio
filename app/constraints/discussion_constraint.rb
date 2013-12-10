class DiscussionConstraint
  def self.matches?(request)

    request_method = request.env['REQUEST_METHOD']
    action         = request.path_parameters[:action]

    case request_method
      when 'GET'
        %w[ new_proposal ].include? action
      when 'POST'
        %w[ update_description add_comment show_description_history edit_title ].include? action
      when 'PUT'
        %w[ move update ].include? action
      when 'DELETE'
        %w[ ].include? action
      else
        false
    end

  end
end
