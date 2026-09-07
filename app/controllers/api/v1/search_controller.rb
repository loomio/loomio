class Api::V1::SearchController < Api::V1::RestfulController
  SEARCHABLE_TYPES = %w[Discussion Comment Poll Stance Outcome].freeze

  def index
    guest_discussion_ids = Topic.where(id: current_user.guest_topic_ids, topicable_type: 'Discussion').pluck(:topicable_id)

    if params[:author_id].present? && group_or_org_id.blank?
      rel = PgSearch::Document.all
    elsif group_or_org_id.blank?
      rel = PgSearch::Document.where("group_id IN (:group_ids) OR discussion_id in (:discussion_ids)", group_ids: group_ids, discussion_ids: guest_discussion_ids)
    elsif group_or_org_id.to_i == 0
      rel = PgSearch::Document.where("group_id is null and discussion_id IN (:discussion_ids)", discussion_ids: guest_discussion_ids)
    else
      rel = PgSearch::Document.where("group_id IN (:group_ids)", group_ids: group_ids)
    end

    if params[:tag]
      tag_topic_ids = Topic.where(group_id: group_ids).where("tags @> ARRAY[?]::varchar[]", Array(params[:tag])).pluck(:id)
      rel = rel.where(topic_id: tag_topic_ids)
    end

    if SEARCHABLE_TYPES.include?(params[:type])
      rel = rel.where(searchable_type: params[:type])
    elsif params[:types].present?
      rel = rel.where(searchable_type: params[:types].split(',') & SEARCHABLE_TYPES)
    end

    rel = rel.where(author_id: params[:author_id].to_i) if params[:author_id].present?

    candidate_rel = rel

    visible_topic = TopicQuery
      .visible_to(
        user: current_user,
        topic_id: PgSearch::Document.arel_table[:topic_id]
      )
      .select(:id)
      .limit(1)
      .offset(0)

    # Keep this as a correlated lookup so PostgreSQL checks visibility only
    # after using the full-text index to find matching search documents.
    rel = rel.where(visible_topic.arel.exists)

    search_documents = PgSearch::Document.arel_table
    kept_discussion = Discussion.kept
      .where(Discussion.arel_table[:id].eq(search_documents[:discussion_id]))
      .select(:id)
      .limit(1)
      .offset(0)

    # Avoid materializing every kept discussion for each search. Documents for
    # standalone polls have no discussion, while discussion documents must
    # still belong to a non-discarded discussion.
    rel = rel.where(
      search_documents[:discussion_id].eq(nil).or(kept_discussion.arel.exists)
    )

    results = if params[:query].blank? && params[:author_id].present?
      rel.order(authored_at: :desc, id: :desc).limit(SearchQuery::RESULT_LIMIT)
    else
      SearchQuery.new(
        relation: rel,
        candidate_relation: candidate_rel,
        query: params[:query],
        order: params[:order]
      ).results
    end
    # results = results.order().offset().limit()

    groups = access_by_id(Group.where(id: results.map(&:group_id)))
    discussions = access_by_id(Discussion.where(id: results.map(&:discussion_id)))
    polls = access_by_id(Poll.where(id: results.map(&:poll_id)))
    authors = access_by_id(User.where(id: results.map(&:author_id)))

    poll_topic_items = access_by_id(
      TopicItem.where("topic_id is not null").where(itemable_type: "Poll", itemable_id: results.map(&:poll_id)),
      :itemable_id
    )

    stance_topic_items = access_by_id(
      TopicItem.where("topic_id is not null").where(itemable_type: "Stance", itemable_id: results.filter { |r| r.searchable_type == 'Stance' }.map(&:searchable_id)),
      :itemable_id
    )

    self.collection = results.map do |res|
      poll = polls[res.poll_id]
      discussion = discussions[res.discussion_id]
      group = groups[res.group_id]
      author = authors[res.author_id]
      title = case res.searchable_type
      when 'Discussion' then discussion&.title
      when 'Poll' then poll&.title
      end
      sequence_id = if discussion
        ((res.searchable_type == "Stance" && stance_topic_items[res.searchable_id]) || poll_topic_items[res.poll_id] || nil)&.sequence_id
      end
      SearchResult.new(
        id: res.id,
        searchable_type: res.searchable_type,
        searchable_id: res.searchable_id,
        poll_title: poll&.title,
        discussion_title: discussion&.title,
        discussion_key: discussion&.key,
        highlight: result_highlight(res, title: title, author_name: author&.name),
        poll_id: res.poll_id,
        poll_key: poll&.key,
        sequence_id: sequence_id,
        group_handle: group&.handle,
        group_key: group&.key,
        group_id: group&.id,
        group_name: group&.full_name,
        author_name: author&.name,
        author_id: res.author_id,
        authored_at: res.authored_at,
        tags: Array(res.tags)
      )
    end

    respond_with_collection
  end


  private
  def result_highlight(result, title:, author_name:)
    return result.pg_search_highlight if params[:query].present? || params[:author_id].blank?

    content = result.content.to_s
    content = content.delete_prefix(title.to_s).strip if title.present?
    content = content.delete_suffix(author_name.to_s).strip if author_name.present?
    ERB::Util.html_escape(content.truncate(240))
  end

  def access_by_id(collection, id_col = 'id')
    h = {}
    collection.each do |row|
      h[row.send(id_col)] = row
    end
    h
  end

  def exclude_types
    'group membership discussion outcome topic_item'.split(' ')
  end

  def group_ids
    if params[:group_id].present?
      current_user.browseable_group_ids & Array(params[:group_id].to_i)
    elsif params[:org_id] == '0'
      []
    elsif params[:org_id].present?
      current_user.browseable_group_ids & Group.find(params[:org_id]).id_and_subgroup_ids
    else
      current_user.browseable_group_ids
    end
  end

  def group_or_org_id
    params[:group_id] || params[:org_id]
  end

  def serializer_root
    :search_results
  end

  def serializer_class
    SearchResultSerializer
  end
end
