class Inbox
  attr_reader :size
  attr_reader :grouped_items

  def initialize(user)
    @user = user
    @size = 0
  end

  def unfollow!(item)
    if @user.can? :unfollow, item
      raise 'no method yet.. should be added to DiscussionReader'
    end
  end

  def load
    @grouped_items = {}
    @motions = unread_motions_for(groups)
    @discussions = unread_discussions_for(groups, exclude_ids: @motions.pluck(:discussion_id))

    @grouped_unread_discussions = @discussions.group_by { |d| d.group }
    @grouped_unread_motions = @motions.group_by { |m| m.group }

    @unread_discussions_count_per_group = {}
    groups.each do |group|
      discussions = @grouped_unread_discussions.fetch(group, [])
      motions = @grouped_unread_motions.fetch(group, [])

      next if discussions.empty? && motions.empty?

      @grouped_items[group] = motions + discussions
    end

    update_size
    self
  end

  def update_size
    @size = 0
    @grouped_items.each_pair{|group, items| @size += items.size }
  end

  def items_count
    count = 0
    @grouped_items.each_pair do |group, items|
      count += items.size
    end
    count
  end

  def empty?
    @grouped_items.empty?
  end

  def items_by_group
    @grouped_items.each_pair do |group, discussions|
      yield group, discussions
    end
  end

  def groups
    @user.inbox_groups
  end

  #group can be group or groups
  def clear_all_in_group(group, last_viewed_at = Time.now)
    unread_discussions_for(group).find_each do |discussion|
      DiscussionReader.for(user: @user, discussion: discussion).viewed!(last_viewed_at)
    end

    unread_motions_for(group).find_each do |motion|
      MotionReader.for(user: @user, motion: motion).viewed!(last_viewed_at)
    end
  end

  def unread_discussions_for(group_or_groups, exclude_ids: [])
    q = Queries::VisibleDiscussions.
      new(user: @user, groups: group_or_groups).not_muted.unread
    q = q.where('discussions.id not in (?)', exclude_ids) if exclude_ids.any?

    q.last_activity_after(6.weeks.ago).
      includes(:group).
      order_by_latest_activity.
      readonly(false).limit(100)
  end

  def unvoted_motions_for(group)
    Queries::UnvotedMotions.for(@user, group)
  end

  def unread_motions_for(group_or_groups)
    Queries::VisibleMotions.
                    new(user: @user, groups: group_or_groups).
                    unread.voting.
                    includes({:discussion => :group}).
                    order_by_latest_activity.readonly(false).limit(100)
  end

  def start_date_for(group)
    @user.memberships.where(group_id: group.id).
    first.
    created_at - 1.week
  end
end
