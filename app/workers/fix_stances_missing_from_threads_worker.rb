class FixStancesMissingFromThreads
  include Sidekiq::Worker
	def perform
		stance_ids = Event.where("discussion_id is not null").where(eventable_type: 'Stance').pluck(:eventable_id)
		poll_ids = Stance.where(id: stance_ids).pluck(:poll_id).uniq
    Stance.joins(:poll).
           where("polls.discussion_id is not null").
           where("reason is not null").
           where("stances.poll_id NOT IN (?)", poll_ids).find_each do |s|
    	s.create_missing_created_event! if s.add_to_discussion?
    end
	end
end