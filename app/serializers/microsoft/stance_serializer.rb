class Microsoft::StanceSerializer < Microsoft::BaseSerializer
  def section_title
    object.eventable.stance_choices.map do |sc|
      if object.eventable.poll.has_variable_score
        "#{sc.poll_option.display_name} (#{sc.score})"
      else
        sc.poll_option.display_name
      end
    end.join(", ")
  end

  def section_subtitle
    object.eventable.reason
  end

  def text_options
    super.merge(poll: object.eventable.poll.title)
  end
end
