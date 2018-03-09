class OutcomeSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :statement, :latest, :created_at, :custom_fields, :announcements_count

  has_one :poll, serializer: PollSerializer
  has_one :poll_option, serializer: PollOptionSerializer
  has_one :author, serializer: UserSerializer

  def custom_fields
    object.custom_fields.except('calendar_invite')
  end
end
