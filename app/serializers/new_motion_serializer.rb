class NewMotionSerializer < ActiveModel::Serializer
  attributes :id, :sequence_id, :kind
  has_one :proposal, serializer: MotionSerializer

  def proposal
    object.eventable
  end
end
