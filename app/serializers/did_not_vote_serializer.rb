class DidNotVoteSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :created_at

  has_one :user, serializer: UserSerializer, root: :users
  has_one :proposal, serializer: MotionSerializer, root: :proposals

  def proposal_id
    object.motion_id
  end

  def proposal
    object.motion
  end
end
