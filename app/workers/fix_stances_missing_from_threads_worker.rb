class FixStancesMissingFromThreadsWorker
  include Sidekiq::Worker
	def perform
		stance_ids = Event.where("topic_id is not null").where(eventable_type: 'Stance').pluck(:eventable_id)
		poll_ids = Stance.where(id: stance_ids).pluck(:poll_id).uniq
    Stance.joins(poll: :topic).
           where("polls.topic_id IS NOT NULL").
           where("topics.topicable_type = 'Discussion'").
           where("reason is not null").
           where("stances.poll_id NOT IN (?)", poll_ids).find_each do |s|
    	s.create_missing_created_event! if s.add_to_thread?
    end
	end
end