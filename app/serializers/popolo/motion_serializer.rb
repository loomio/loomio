class Popolo::MotionSerializer < ActiveModel::Serializer
  attributes :organization_id,
             :creator_id,
             :text,
             :classification,
             :date,
             :requirement,
             :result

  def organization_id
    object.group.name.parameterize
  end

  def creator_id
    object.author.name.parameterize
  end

  def text
    object.description
  end

  def classification
    'proposal'
  end

  def date
    object.created_at
  end

  def requirement
    'consensus'
  end

  def result
    object.outcome
  end
end
