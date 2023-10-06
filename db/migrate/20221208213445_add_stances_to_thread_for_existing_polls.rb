class AddStancesToThreadForExistingPolls < ActiveRecord::Migration[6.1]
  def change
    raise "You need to update to v2.17.1 and migrate your database before you can update to latest" unless Loomio::Version.current == "2.17.1"
    Poll.where("discussion_id is not null and stances_in_discussion is false").each do |poll|
      poll.update(stances_in_discussion: true)

      stance_ids = poll.stances.latest.reject(&:body_is_blank?).map(&:id)

      if (poll.closed? || poll.hide_results != 'until_closed')
        Event.where(kind: 'stance_created', eventable_id: stance_ids).update_all(discussion_id: poll.discussion_id)
        EventService.repair_thread(poll.discussion_id)
      end

      if poll.closed?
        sequence_ids = Event.where(kind: 'stance_created', eventable_id: stance_ids).pluck(:sequence_id)
        DiscussionReader.where(discussion_id: poll.discussion_id).each do |reader|
          reader.mark_as_read(sequence_ids)
          reader.save!
        end
      end
    end
  end
end
