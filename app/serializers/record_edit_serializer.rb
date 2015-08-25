class RecordEditSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :previous_values,
             :new_values

  has_one :discussion
  has_one :proposal
  has_one :author, root: 'users'

  def discussion
    object.record
  end

  def proposal
    object.record
  end

  def include_discussion?
    object.record_type == 'Discussion'
  end

  def include_proposal?
    object.record_type == 'Motion'
  end
end
