class Popolo::MotionSerializer < ActiveModel::Serializer
  attributes :motion_id,
             :organization_id,
             :creator_id,
             :text,
             :classification,
             :start_date,
             :end_date,
             :requirement,
             :result,
             :counts
  has_many :unique_votes, key: :votes, serializer: Popolo::VoteSerializer

  def motion_id
    object.key
  end

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

  def start_date
    object.created_at
  end

  def end_date
    object.closed_at || object.closing_at
  end

  def requirement
    'consensus'
  end

  def result
    object.outcome
  end

  def counts
    object.vote_counts.keys.map { |key| { option: key, value: object.vote_counts[key] } }
  end
end
