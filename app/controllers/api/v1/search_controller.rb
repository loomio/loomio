class API::V1::SearchController < API::V1::RestfulController
  def index
    if group_or_org_id.to_i == 0
      rel = PgSearch.multisearch(params[:query]).where("group_id is null and discussion_id IN (:discussion_ids)", discussion_ids: current_user.guest_discussion_ids)
    end

    if group_or_org_id.to_i > 0
      rel = PgSearch.multisearch(params[:query]).where("group_id IN (:group_ids)", group_ids: group_ids)
    end

    if group_or_org_id.blank?
      rel = PgSearch.multisearch(params[:query]).where("group_id IN (:group_ids) OR discussion_id in (:discussion_ids)", group_ids: group_ids, discussion_ids: current_user.guest_discussion_ids)
    end

    if params[:tag]
      discussion_ids = Discussion.where(group_id: group_ids).where("tags @> ARRAY[?]::varchar[]", Array(params[:tag])).pluck(:id)
      poll_ids = Poll.where(group_id: group_ids).where("tags @> ARRAY[?]::varchar[]", Array(params[:tag])).pluck(:id)
      rel = rel.where("discussion_id in (:discussion_ids) or poll_id in (:poll_ids)", discussion_ids: discussion_ids, poll_ids: poll_ids)
    end

    if %w[Discussion Comment Poll Stance Outcome].include?(params[:type])
      rel = rel.where(searchable_type: params[:type])
    end

    if params[:order] == 'authored_at_desc'
      rel = rel.reorder('authored_at desc')
    end

    if params[:order] == 'authored_at_asc'
      rel = rel.reorder('authored_at asc')
    end

    results = rel.limit(20).with_pg_search_highlight.all
    # results = results.order().offset().limit()

    groups = access_by_id(Group.where(id: results.map(&:group_id)))
    discussions = access_by_id(Discussion.where(id: results.map(&:discussion_id)))
    polls = access_by_id(Poll.where(id: results.map(&:poll_id)))
    authors = access_by_id(User.where(id: results.map(&:author_id)))

    poll_events = access_by_id(
      Event.where("discussion_id is not null").where(eventable_type: "Poll", eventable_id: results.map(&:poll_id)), 
      :eventable_id
    )

    stance_events = access_by_id(
      Event.where("discussion_id is not null").where(eventable_type: "Stance", eventable_id: results.filter {|r| r.searchable_type == 'Stance'}.map(&:searchable_id)), 
      :eventable_id
    )

    self.collection = results.map do |res|
      poll = polls[res.poll_id]
      discussion = discussions[res.discussion_id] 
      group = groups[res.group_id]
      author = authors[res.author_id]
      sequence_id = ((res.searchable_type == "Stance" && stance_events[res.searchable_id]) || poll_events[res.poll_id] || nil)&.sequence_id
      SearchResult.new(
        id: res.id,
        searchable_type: res.searchable_type,
        searchable_id: res.searchable_id,
        poll_title: poll&.title,
        discussion_title: discussion&.title,
        discussion_key: discussion&.key,
        highlight: res.pg_search_highlight,
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
        tags: (Array(poll&.tags) + Array(discussion&.tags)).uniq
      )
    end

    respond_with_collection
  end


  private
  def access_by_id(collection, id_col = 'id')
    h = {}
    collection.each do |row|
      h[row.send(id_col)] = row
    end
    h
  end

  def exclude_types
    'group membership discussion outcome event'.split(' ')
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
