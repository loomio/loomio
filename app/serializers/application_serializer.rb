class ApplicationSerializer < ActiveModel::Serializer
  embed :ids, include: true

  def include_discussion?
    !Array(scope[:exclude_records]).include?('discussion')
  end

  def include_group?
    !Array(scope[:exclude_records]).include?('group')
  end

  def include_eventable?
    !Array(scope[:exclude_records]).include?(object.eventable_type.downcase)
  end

  def include_poll_options?
    !Array(scope[:exclude_records]).include?('poll_option')
  end

  def include_stances?
    !Array(scope[:exclude_records]).include?('stance')
  end

  def include_stance_choices?
    !Array(scope[:exclude_records]).include?('stance_choice')
  end

  def include_author?
    !Array(scope[:exclude_records]).include?('user')
  end

  def include_author?
    !Array(scope[:exclude_records]).include?('user')
  end

  def include_outcome?
    !Array(scope[:exclude_records]).include?('outcome')
  end

  def include_current_outcome?
    !Array(scope[:exclude_records]).include?('outcome')
  end

  def include_outcomes?
    !Array(scope[:exclude_records]).include?('outcome')
  end
end
