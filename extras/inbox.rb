class Inbox
  attr_reader :size

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
    @unread_discussions_per_group = {}
    groups.each do |group|
      @unread_discussions_per_group[group] = unread_discussions_for(group).size

      discussions = unread_discussions_for(group).limit(unread_per_group_limit)
      motions = unvoted_motions_for(group)
      next if discussions.empty? && motions.empty?

      aligned_items = []
      motions.each do |motion|
        aligned_items << motion
        aligned_items << motion.discussion if discussions.include?(motion.discussion)
      end
      other_discussions = discussions - aligned_items
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
    @unread_discussions_per_group[group]
  end

  def unread_per_group_limit
    20
  end

  def unread_items_exceeds_max_for(group)
    unread_count_for(group) > unread_per_group_limit
  end

  def items_not_shown_count_for(group)
    unread_count_for(group) - unread_per_group_limit
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
