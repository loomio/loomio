class MembershipRequestSerializer < ApplicationSerializer
  attributes :id, :group_id, :name, :email, :introduction, :approved_at, :declined_at, :decline_reason, :created_at, :updated_at, :requestor_email

  has_one :responder, serializer: AuthorSerializer, root: :users
  has_one :requestor, serializer: AuthorSerializer, root: :users

  def requestor_email
    requestor&.email
  end
end
