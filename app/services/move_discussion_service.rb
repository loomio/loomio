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

  def user_is_member_of_destination?
    destination_group.members.include? user
  end

  def valid?
    user_is_admin_of_source? && user_is_member_of_destination?
  end

  def move!
    if discussion.public? && destination_group.is_hidden?
      discussion.private = true
    end
    discussion.group = destination_group if valid?
    discussion.save!
  end
end

