class InboxController < BaseController
  def index
    load_inbox
    build_discussion_index_caches
    render layout: false if request.xhr?
  end

  def size
    size = Queries::VisibleDiscussions.
            new(groups: current_user.inbox_groups,
                user: current_user).
            unread.
            last_activity_after(6.weeks.ago).
            order_by_latest_activity.
            count

    if size > 100
      render text: '100+'
    elsif size > 0
      render text: size
    else
      render text: ''
    end
  end

  def preferences
    @inbox_preferences_form = InboxPreferencesForm.new(current_user)
  end

  def update_preferences
    @inbox_preferences_form = InboxPreferencesForm.new(current_user)
    @inbox_preferences_form.submit(params)
    redirect_to inbox_path
  end

  def mark_as_read
    if params.has_key?(:discussion_ids)
      ids = params[:discussion_ids].split('x').map(&:to_i)
      discussions = current_user.discussions.published.where(id: ids)
      discussions.each do |discussion|
        DiscussionReader.for(user: current_user, discussion: discussion).viewed!
      end
    end

    if params.has_key?(:motion_ids)
      ids = params[:motion_ids].split('x').map(&:to_i)
      motions = current_user.motions.where(id: ids)
      motions.each do |motion|
        MotionReader.for(user: current_user, motion: motion).viewed!
      end
    end

    redirect_back_or_head_ok
  end

  # doh.. I ment mark all in group as read.. sigh
  def mark_all_as_read
    @inbox = Inbox.new(current_user)
    group = current_user.groups.find(params[:id])
    @inbox.clear_all_in_group(group)
    redirect_back_or_head_ok
  end

  def unfollow
    item = load_resource_from_params
    @inbox.unfollow!(item)
    redirect_back_or_head_ok
  end

  private

  def build_discussion_index_caches
    @discussions = []
    @motions = []
    @inbox.items_by_group do |group, items|
      items.each do |item|
        if item.kind_of? Discussion
          @discussions << item
        elsif item.kind_of? Motion
          @motions << item
        end
      end
    end

    if current_user
      @motion_readers = MotionReader.where(user_id: current_user.id,
                                           motion_id: @motions.map(&:id) ).includes(:motion)
      @last_votes = Vote.most_recent.where(user_id: current_user, motion_id: @motions.map(&:id))
    else
      @motion_readers = []
      @last_votes = []
    end

    @discussion_reader_cache = DiscussionReaderCache.new(user: current_user,
                                                         discussions: @discussions)
    @motion_reader_cache = MotionReaderCache.new(current_user, @motion_readers)

    @last_vote_cache = VoteCache.new(current_user, @last_votes)
  end

  def redirect_back_or_head_ok
    if request.xhr?
      load_inbox
      size = @inbox.items_count
      size = '' if size == 0
      render js: "$('#inbox-count').text('#{size}')"
    else
      redirect_to inbox_path
    end
  end

  def load_inbox
    unless @inbox
      @inbox = Inbox.new(current_user)
      @inbox.load
    end
  end

  def load_resource_from_params
    class_name = params[:class]
    id = params[:id]

    if class_name == 'Discussion'
      current_user.discussions.find_by_id(id)
    elsif class_name == 'Motion'
      current_user.motions.find_by_id(id)
    end
  end

end
