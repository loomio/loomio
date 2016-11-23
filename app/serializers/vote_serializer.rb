class VoteSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :kind, :statement, :proposal_id, :created_at, :stance

  has_one :author, serializer: UserSerializer, root: :users
  has_one :proposal, serializer: MotionSerializer, root: :proposals

  def proposal_id
    object.motion_id
  end

  def proposal
    object.motion
  end
end
