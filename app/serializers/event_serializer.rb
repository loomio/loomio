class EventSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :sequence_id, :kind, :discussion_id, :created_at

  has_one :actor, serializer: UserSerializer, root: 'users'
  has_one :membership_request, serializer: MembershipRequestSerializer, root: 'membership_requests'

  def include_membership_request?
    ['membership_requested', 'membership_request_approved'].include? object.kind
  end

  def membership_request
    object.eventable
  end

  def actor
    object.eventable.try(:user)
  end
end
