class DemoService
	def self.refill_queue
		return unless ENV['FEATURES_DEMO_GROUPS']

		demo = Demo.where('demo_handle is not null').last
		ids = Redis::List.new('demo_group_ids').value

		expected = 3
		remaining = Group.where(id: ids).where('created_at < ?', 24.hours.ago).count

		(expected - remaining).times do
			group = RecordCloner.new(recorded_at: demo.recorded_at).create_clone_group(demo.group)
			ids.push group.id
		end

		# Group.where(id: ids).where('created_at < ?', 24.hours.ago).delete_all
	end

	def self.take_demo(actor)
		ids = Redis::List.new('demo_group_ids')
		group = Group.find(ids.shift)
    group.creator = actor
    group.subscription = Subscription.new(plan: 'demo', owner: actor)
    group.add_member! actor
    group.save!
   	group
	end

	def self.generate_demo_groups
		Demo.where("demo_handle IS NOT NULL").each do |template|
			Group.where(handle: template.demo_handle).update_all(handle: nil)
	    RecordCloner.new(recorded_at: template.recorded_at)
									.create_clone_group_for_public_demo(template.group, template.demo_handle)
		end
	end
end