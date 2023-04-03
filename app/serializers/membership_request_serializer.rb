class MembershipRequestSerializer < ApplicationSerializer
  attributes :id, :group_id, :name, :email, :introduction, :responded_at, :response, :created_at, :updated_at, :requestor_email

  has_one :responder, serializer: AuthorSerializer, root: :users
  has_one :requestor, serializer: AuthorSerializer, root: :users

  def requestor_email
    requestor&.email
  end
end
