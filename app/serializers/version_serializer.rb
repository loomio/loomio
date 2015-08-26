class VersionSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :changes

  has_one :discussion
  has_one :proposal

  def changes
    object.object_changes
  end

  def discussion
    object.item
  end

  def proposal
    object.item
  end

  def include_discussion?
    object.item_type == 'Discussion'
  end

  def include_proposal?
    object.item_type == 'Motion'
  end
end
