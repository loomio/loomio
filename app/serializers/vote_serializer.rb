class VoteSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :position, :statement, :proposal_id, :created_at

  has_one :author, serializer: UserSerializer, root: :users
  has_one :proposal, serializer: MotionSerializer, root: :proposals

  def proposal_id
    object.motion_id
  end

  def proposal
    object.motion
  end
end
