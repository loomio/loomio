class ActivitySummary
  UNREAD_PER_GROUP_LIMIT = 20
  MAX_DAYS_OF_ACTIVITY = 7

  attr_reader :grouped_items
  attr_reader :last_sent_at
  attr_reader :user

  def initialize(user, last_sent_at)
    limit = MAX_DAYS_OF_ACTIVITY.days.ago
    last_sent_at = limit if last_sent_at.nil? || last_sent_at <= limit
    @last_sent_at = last_sent_at
    @user = user
  end

  def load
    @grouped_items = {}
    @user.groups.each do |group|

      discussions = unread_discussions_for(group).limit(UNREAD_PER_GROUP_LIMIT)
      motions = unread_motions_for(group)
      next if discussions.empty? && motions.empty?

      motion_discussions = []
      motions.each { |motion| motion_discussions << motion.discussion }
      @grouped_items[group] = (motion_discussions + discussions).flatten.uniq
    end
    self
  end

  def items_by_group
    @grouped_items.each_pair do |group, discussions|
      yield group, discussions
    end
  end

  def unread_discussions_for(group)
    limit = [start_date_for(group), MAX_DAYS_OF_ACTIVITY.days.ago].max
    Queries::VisibleDiscussions.new(user: @user, groups: [group])
                               .unread
                               .last_comment_after(limit)
                               .order_by_latest_comment
                               .readonly(false)
  end

  def unread_motions_for(group)
    limit = [start_date_for(group), MAX_DAYS_OF_ACTIVITY.days.ago].max
    Queries::VisibleMotions.new(user: @user, groups: [group])
                           .unread
                           .active_since(limit)
                           .voting
                           .order_by_latest_activity
                           .readonly(false)
  end

  def start_date_for(group)
    @user.memberships.where(group_id: group.id).first.
    created_at - 1.week
  end
end
