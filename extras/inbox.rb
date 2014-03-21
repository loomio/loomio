class Inbox
  UNREAD_PER_GROUP_LIMIT = 20
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
    @discussions = unread_discussions_for(groups)
    @motions = unread_motions_for(groups)

    @grouped_unread_discussions = @discussions.group_by { |d| d.group }
    @grouped_unread_motions = @motions.group_by { |m| m.group }

    @unread_discussions_count_per_group = {}
    groups.each do |group|
      discussions = @grouped_unread_discussions[group]

      next if discussions.nil?

      limited_discussions = discussions.first(unread_per_group_limit)
      @unread_discussions_count_per_group[group] = discussions.size
      motions = @grouped_unread_motions.fetch(group, [])

      next if limited_discussions.empty? && motions.empty?

      aligned_items = []

      motions.each do |motion|
        aligned_items << motion
        aligned_items << motion.discussion if discussions.include?(motion.discussion)
      end

      other_discussions = limited_discussions - aligned_items
      @grouped_items[group] = aligned_items + other_discussions
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

  def unread_count_for(group)
    @unread_discussions_count_per_group[group]
  end

  def unread_per_group_limit
    UNREAD_PER_GROUP_LIMIT
  end

  def unread_items_exceeds_max_for(group)
    unread_count_for(group) > unread_per_group_limit
  end

  def items_not_shown_count_for(group)
    unread_count_for(group) - unread_per_group_limit
  end

  def groups
    @user.groups.where('memberships.inbox_position is not null').order(:inbox_position)
  end

  def clear_all_in_group(group)
    unread_discussions_for(group).each do |discussion|
      DiscussionReader.for(user: @user, discussion: discussion).viewed!
    end

    unread_motions_for(group).each do |motion|
      MotionReader.for(user: @user, motion: motion).viewed!
    end
  end

  def unread_discussions_for(group_or_groups)
    Queries::VisibleDiscussions.
      new(user: @user, groups: group_or_groups).
      unread.
      last_comment_after(3.months.ago).
      includes(:group).
      order_by_latest_comment.readonly(false)
  end

  def unvoted_motions_for(group)
    Queries::UnvotedMotions.for(@user, group)
  end

  def unread_motions_for(group_or_groups)
    Queries::VisibleMotions.
                    new(user: @user, groups: group_or_groups).
                    unread.voting.
                    includes({:discussion => :group}).
                    order_by_latest_activity.readonly(false)
  end

  def start_date_for(group)
    @user.memberships.where(group_id: group.id).
    first.
    created_at - 1.week
  end
end
