Queries::Notified::Default = Struct.new(:kind, :model, :user) do

  def results
    send(kind)
  end

  private

  def notified_group
    Array((Notified::Group.new(model.group, user) if model.group.presence))
  end

  def notified_participants
    model.participants.where.not(id: user).map { |participant| Notified::User.new(participant) }
  end

  alias :new_discussion    :notified_group
  alias :discussion_edited :notified_group
  alias :poll_created      :notified_group
  alias :poll_edited       :notified_participants
  alias :poll_option_added :notified_participants
  alias :outcome_created   :notified_group

end
