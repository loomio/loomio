class MigrateGuestsService
  def self.migrate!
    DiscussionReader.joins(:discussion).where('discussions.group_id': nil).update_all(guest: true)
    Stance.joins(:poll).where('polls.group_id': nil).update_all(guest: true)
    Group.order('discussions_count desc').pluck(:id).each do |id|
      MigrateGuestOnDiscussionReadersAndStances.perform_async(id)
    end
  end
end
