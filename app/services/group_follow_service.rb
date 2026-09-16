class GroupFollowService
  def self.create(group_follow:, actor:)
    actor.ability.authorize!(:follow, group_follow.group)
    group_follow.user = actor
    group_follow.save!
    group_follow
  rescue ActiveRecord::RecordNotUnique
    actor.group_follows.find_by!(group: group_follow.group)
  end

  def self.destroy(group_follow:, actor:)
    raise CanCan::AccessDenied unless group_follow.user_id == actor.id

    group_follow.destroy!
  end
end
