module Ability::Task
  def initialize(user)
    super(user)

    can [:update], ::Task do |task|
      (task.author_id == user.id) || can?(:update, task.record) || (task.users.exists? user.id)
    end
  end
end
