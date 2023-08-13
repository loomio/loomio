class API::V1::SearchController < API::V1::RestfulController

  def index
    # trying to write it all directly here .. hopefully faster..
    # how would I write this with our normal serializer pattern?

    queryTypes = params[:query_types].split("-").filter do |t|
      %w[Discussion Comment Poll Stance Outcome].include?(t)
    end

    results = PgSearch.multisearch(params[:query]).where(group_id: group_ids, searchable_type: queryTypes).limit(20).with_pg_search_highlight.all

    # results = results.order().offset().limit()

    groups = access_by_id(Group.where(id: results.map(&:group_id)))
    discussions = access_by_id(Discussion.where(id: results.map(&:discussion_id)))
    polls = access_by_id(Poll.where(id: results.map(&:poll_id)))
    authors = access_by_id(User.where(id: results.map(&:author_id)))
    # poll_events = access_by_poll_id(Event.where("discussion_id IS NOT NULL").where(eventable(polls))

    data = results.map do |res|
      poll = polls[res.poll_id]
      discussion = discussions[res.discussion_id] 
      group = groups[res.group_id]
      author = authors[res.author_id]
      {
        id: res.id,
        searchable_type: res.searchable_type,
        searchable_id: res.searchable_id,
        poll_title: poll&.title,
        bum: "big bum",
        discussion_title: discussion&.title,
        discussion_key: discussion&.key,
        highlight: res.pg_search_highlight,
        poll_key: poll&.key,
        group_handle: group&.handle,
        group_key: group&.key,
        group_name: group&.full_name,
        author_name: author&.name,
        author_id: res.author_id,
        tags: (Array(poll&.tags) + Array(discussion&.tags)).uniq,
        content: res.content
      }
    end.as_json

    render json: data, root: false
  end

  def access_by_id(collection)
    h = {}
    collection.each do |row|
      h[row.id] = row
    end
    h
  end

  private
  def group_ids
    if params[:org_id].present?
      current_user.group_ids & Group.find(params[:org_id]).id_and_subgroup_ids
    else
      current_user.group_ids
    end
  end

  def search_params
    params.slice(:from, :per)
  end

  def serializer_root
    :search_results
  end

  def serializer_class
    SearchResultSerializer
  end
end
