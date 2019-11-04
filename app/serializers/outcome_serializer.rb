class OutcomeSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :statement, :statement_format, :latest,
    :created_at, :custom_fields, :attachments, :event_summary, :event_location

  has_one :poll, serializer: PollSerializer
  has_one :poll_option, serializer: PollOptionSerializer
  has_one :author, serializer: UserSerializer
  has_many :reactions, serializer: ReactionSerializer, root: :reactions

  def include_reactions?
    scope.dig(:cache, :reactions).present?
  end
  def reactions
    scope.dig(:cache, :reactions).get_for(object)
  end

  def custom_fields
    object.custom_fields.except('calendar_invite')
  end

  private

  # pull the specified attributes from the cache passed in via serializer scope
  # This allows us to make 1 query to fetch all documents, or reactors for a series
  # of comments, rather than needing to do a separate query for each comment
  def from_cache(field)
    scope.dig(:cache, field, object.id)
  end

  def scope
    Hash(super)
  end

end
