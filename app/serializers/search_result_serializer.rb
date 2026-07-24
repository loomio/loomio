class SearchResultSerializer < ApplicationSerializer
  attributes :id,
             :searchable_type,
             :searchable_id,
             :poll_title,
             :discussion_title,
             :discussion_key,
             :highlight,
             :poll_key,
             :poll_id,
             :sequence_id,
             :group_id,
             :group_handle,
             :group_key,
             :group_name,
             :author_name,
             :author_id,
             :authored_at,
             :tags

  has_one :author, serializer: AuthorSerializer, root: :users
  has_one :poll, serializer: PollSerializer, root: :polls

  def include_author?
    !anonymous_stance?
  end

  def include_author_id?
    !anonymous_stance?
  end

  def include_author_name?
    !anonymous_stance?
  end

  def include_authored_at?
    !anonymous_stance?
  end

  def searchable_id
    return object.searchable_id unless anonymous_stance?

    Stance.anonymous_id_for(poll_id: object.poll_id, stance_id: object.searchable_id)
  end

  def id
    return object.id unless anonymous_stance?

    Stance.anonymous_id_for(poll_id: object.poll_id, stance_id: "search:#{object.searchable_id}")
  end

  def include_sequence_id?
    !anonymous_stance?
  end

  private

  def anonymous_stance?
    object.searchable_type == 'Stance' && object.poll&.anonymous?
  end
end
