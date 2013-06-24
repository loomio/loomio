class Inbox
  def initialize(user)
    @user = user
  end

  def mark_all_as_read!(group)
    unread_discussions_for(group).each do |discussion|
      ViewLogger.discussion_viewed(discussion, @user)
    end
  end 

  def mark_as_read!(item)
    if @user.can? :show, item
      ViewLogger.discussion_viewed(item, @user)
    end
  end

  def unfollow!(item)
    if @user.can? :unfollow, item
      ViewLogger.discussion_unfollowed(item, @user)
    end
  end

  def load
    @grouped_items = {}
    groups.each do |group|
      discussions = unread_discussions_for(group)
      motions = unvoted_motions_for(group)
      next if discussions.empty? && motions.empty?
      @grouped_items[group] = motions + discussions
    end
    self
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
    @user.memberships.where('inbox_position is not null').order(:inbox_position).map(&:group)
  end

  def unread_discussions_for(group)
    Queries::UnreadDiscussions.for(@user, group).order('last_comment_at DESC').readonly(false)
  end

  def unvoted_motions_for(group)
    Queries::UnvotedMotions.for(@user, group)
  end
end
