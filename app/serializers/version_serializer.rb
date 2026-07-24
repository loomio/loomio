class VersionSerializer < ApplicationSerializer
  attributes :id,
             :whodunnit,
             :previous_id,
             :created_at,
             :item_id,
             :item_type,
             :object_changes

  # has_one :discussion
  # has_one :comment
  # has_one :poll
  # has_one :stance

  def whodunnit
    object.whodunnit.to_i
  end

  # Anonymous polls must not reveal who cast a stance. PaperTrail records the
  # voter id in `whodunnit` and the (possibly redacted) reason text in
  # `object_changes`, neither of which StanceSerializer exposes for anonymous
  # polls — so suppress them here too.
  def include_whodunnit?
    !hide_anonymous_stance_identity?
  end

  def include_object_changes?
    !hide_anonymous_stance_data?
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

  private

  def stance_item
    object.item if object.item_type == 'Stance'
  end

  def hide_anonymous_stance_identity?
    stance = stance_item
    stance.present? && stance.poll&.anonymous?
  end

  def hide_anonymous_stance_data?
    stance = stance_item
    stance.present? && (stance.poll&.anonymous? || stance.redacted_at.present?)
  end
end
