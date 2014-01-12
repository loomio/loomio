class EventSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :sequence_id, :kind, :discussion_id, :relationships

  has_one :comment, serializer: CommentSerializer
  has_one :proposal, serializer: MotionSerializer, root: :proposals

  %w[comment motion].each do |kind|
    define_method kind do
      object.eventable if object.eventable_type == kind.classify
    end
  end

  def proposal
    motion
  end

  def filter(keys)
    keys.delete(:comment) unless object.eventable_type == 'Comment'
    keys.delete(:proposal) unless object.eventable_type == 'Motion'
    keys
  end

  def relationships
    {
      comment: {foreign_key: 'comment_id', collection: 'comments'},
      proposal: { foreign_key: 'proposal_id', collection: 'proposals' }
    }
  end

end
