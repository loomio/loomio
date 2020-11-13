class OutcomeSerializer < ApplicationSerializer
  attributes :id, :statement, :statement_format, :latest,
    :created_at, :custom_fields, :attachments, :event_summary, :review_on,
    :event_location, :poll_id, :poll_option_id, :group_id, :author_id, :secret_token, :versions_count

  # has_one :poll_option, serializer: PollOptionSerializer, root: :poll_options
  has_one :author, serializer: AuthorSerializer, root: :users

  def custom_fields
    object.custom_fields.except('calendar_invite')
  end
end
