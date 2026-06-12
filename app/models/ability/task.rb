module Ability::Task
  def initialize(user)
    super(user)

    can :show, ::Task do |task|
      task.present? &&
      can?(:show, task.record) &&
      (task.author_id == user.id || task.doer_id == user.id || task.users.exists?(user.id))
    end

    can [:update], ::Task do |task|
      task.present? &&
      can?(:show, task.record) &&
      (task.author_id == user.id || can?(:update, task.record) || task.users.exists?(user.id))
    end
  end
end
