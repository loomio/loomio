class VersionSerializer < ApplicationSerializer
  attributes :id,
             :whodunnit,
             :previous_id,
             :created_at,
             :item_id,
             :item_type,
             :object_changes

  has_one :discussion
  has_one :comment
  has_one :poll
  has_one :stance

  def whodunnit
    object.whodunnit.to_i
  end

  def discussion
    object.item
  end

  def poll
    object.item
  end

  def comment
    object.item
  end

  def stance
    object.item
  end

  def previous_id
    object.previous.try :id
  end

  def include_discussion?
    object.item_type == 'Discussion'
  end

  def include_poll?
    object.item_type == 'Poll'
  end

  def include_comment?
    object.item_type == 'Comment'
  end

  def include_stance?
    object.item_type == 'Stance'
  end
end
