class Inbox
  def initialize(user)
    @user = user
  end

  def unfollow!(item)
    if @user.can? :unfollow, item
      raise 'no method yet.. should be added to DiscussionReader'
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
    @user.memberships.where('inbox_position is not null').order(:inbox_position).map(&:group)
  end

  def unread_discussions_for(group)
    Queries::VisibleDiscussions.new(user: @user, groups: [group]).unread.
                                order_by_latest_comment.readonly(false)
  end

  def unvoted_motions_for(group)
    Queries::UnvotedMotions.for(@user, group)
  end
end
