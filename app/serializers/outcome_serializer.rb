class OutcomeSerializer < ApplicationSerializer
  attributes :id,
             :statement,
             :statement_format,
             :content_locale,
             :latest,
             :created_at,
             :event_summary,
             :event_location,
             :attachments,
             :link_previews,
             :event_summary,
             :review_on,
             :event_location,
             :poll_id,
             :poll_option_id,
             :group_id,
             :author_id,
             :secret_token,
             :versions_count

  has_one :author, serializer: AuthorSerializer, root: :users

  def group_id
    (cache_fetch(:polls_by_id, poll_id) { object.poll }).group_id
  end
end
