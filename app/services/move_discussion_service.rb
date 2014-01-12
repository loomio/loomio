class MoveDiscussionService
  attr_accessor :discussion, :source_group, :destination_group, :user

  def initialize(discussion: nil,
                 destination_group: nil,
                 user: nil)
    @discussion = discussion
    @source_group = discussion.group
    @destination_group = destination_group
    @user = user
  end


  def user_is_admin_of_source?
    discussion.group.admins.include? user
  end

  def user_is_admin_of_destination?
    destination_group.admins.include? user
  end

  def destination_group_is_related_to_source_group?
    if source_group.parent
      (source_group.parent == destination_group) ||
      (source_group.parent == destination_group.parent)
    else
      destination_group.parent == source_group
    end
  end

  def valid?
    user_is_admin_of_source? && user_is_admin_of_destination? && destination_group_is_related_to_source_group?
  end

  def move!
    if discussion.public? && destination_group.is_hidden?
      discussion.private = true
    end
    discussion.group = destination_group if valid?
    discussion.save!
  end
end

