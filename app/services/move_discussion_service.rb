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

  def valid?
    user.ability.can?(:move, discussion) && destination_group.members.include?(user)
  end

  def move!
    if valid?
      discussion.private = true  if destination_group.private_discussions_only?
      discussion.private = false if destination_group.public_discussions_only?
      discussion.group = destination_group
      discussion.save!
    end
  end
end

