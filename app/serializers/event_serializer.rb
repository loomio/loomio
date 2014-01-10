class EventSerializer < ActiveModel::Serializer
  attributes :id, :sequence_id, :kind

  has_one :comment, serializer: CommentSerializer
  has_one :proposal, serializer: MotionSerializer

  %w[comment motion].each do |kind|
    define_method kind do
      object.eventable if object.eventable_type == kind.classify
    end
  end

  def proposal
    motion
  end

end
