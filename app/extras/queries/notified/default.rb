Queries::Notified::Default = Struct.new(:model, :user, :kind)

  def results
    send(kind)
  end

  private

  alias :new_discussion    :notified_group
  alias :discussion_edited :notified_group
  alias :poll_created      :notified_group
  alias :poll_edited       :notified_participants
  alias :outcome_created   :notified_group

  def notified_group
    Array((Notified::Group.new(model.group, user) if model.group))
  end

  def notified_participants
    model.participants.without(user).map { |participant| Notified::User.new(participant) }
  end
end
