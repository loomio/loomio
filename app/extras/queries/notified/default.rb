Queries::Notified::Default = Struct.new(:kind, :model, :user) do

  def results
    raise ActiveRecord::RecordNotFound unless respond_to?(kind, true)
    send(kind)
  end

  private

  def notified_group
    Array((Notified::Group.new(model.group, user) if model.group.presence))
  end

  def notified_group_optional
    Array((notified_group if model.announcements_count == 0))
  end

  def notified_participants
    model.participants.where.not(id: user).map { |participant| Notified::User.new(participant) }
  end

  alias :new_discussion       :notified_group
  alias :discussion_edited    :notified_group
  alias :discussion_announced :notified_group_optional
  alias :poll_created         :notified_group
  alias :poll_edited          :notified_participants
  alias :poll_option_added    :notified_participants
  alias :poll_announced       :notified_group_optional
  alias :outcome_created      :notified_group
  alias :outcome_announced    :notified_group_optional

end
