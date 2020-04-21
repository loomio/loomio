class ApplicationSerializer < ActiveModel::Serializer
  embed :ids, include: true

  def exclude_type?(type)
    !Array((scope || {})[:exclude_types]).include?(type)
  end

  def include_discussion?
    exclude_type?('discussion')
  end

  def include_group?
    exclude_type?('group')
  end

  def include_eventable?
    exclude_type?(object.eventable_type.downcase)
  end

  def include_poll_options?
    exclude_type?('poll_option')
  end

  def include_stances?
    exclude_type?('stance')
  end

  def include_stance_choices?
    exclude_type?('stance_choice')
  end

  def include_participant?
    exclude_type?('user')
  end
  
  def include_user?
    exclude_type?('user')
  end

  def include_author?
    exclude_type?('user')
  end

  def include_outcome?
    exclude_type?('outcome')
  end

  def include_current_outcome?
    exclude_type?('outcome')
  end

  def include_outcomes?
    exclude_type?('outcome')
  end
end
