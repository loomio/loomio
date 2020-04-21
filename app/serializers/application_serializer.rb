class ApplicationSerializer < ActiveModel::Serializer
  embed :ids, include: true

  def exclude_record?(type)
    !Array((scope || {})[:exclude_records]).include?(type)
  end

  def include_discussion?
    exclude_record?('discussion')
  end

  def include_group?
    exclude_record?('group')
  end

  def include_eventable?
    exclude_record?(object.eventable_type.downcase)
  end

  def include_poll_options?
    exclude_record?('poll_option')
  end

  def include_stances?
    exclude_record?('stance')
  end

  def include_stance_choices?
    exclude_record?('stance_choice')
  end

  def include_participant?
    exclude_record?('user')
  end
  
  def include_user?
    exclude_record?('user')
  end

  def include_author?
    exclude_record?('user')
  end

  def include_outcome?
    exclude_record?('outcome')
  end

  def include_current_outcome?
    exclude_record?('outcome')
  end

  def include_outcomes?
    exclude_record?('outcome')
  end
end
