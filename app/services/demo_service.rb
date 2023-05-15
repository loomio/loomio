class DemoService
	def self.refill_queue
		return unless ENV['FEATURES_DEMO_GROUPS']
		demo = Demo.where('demo_handle is not null').last
		return unless demo

		# precache translations
		%w[fr de es pt it uk].each do |locale|
			TranslationService.translate_group_content!(demo.group, locale, true)
		end

		expected = ENV.fetch('FEATURES_DEMO_GROUPS_SIZE', 3)
		remaining = Redis::List.new('demo_group_ids').value.size

		(expected - remaining).times do
			group = RecordCloner.new(recorded_at: demo.recorded_at).create_clone_group(demo.group)
			Redis::List.new('demo_group_ids').push(group.id)
		end
	end

	def self.take_demo(actor)
		group = Group.find(Redis::List.new('demo_group_ids').shift)
    group.creator = actor
    group.subscription = Subscription.new(plan: 'demo', owner: actor)
    group.add_member! actor
    group.save!

    if actor.locale != "en"
	    TranslationService.translate_group_content!(group, actor.locale)
	  end

    EventBus.broadcast('demo_started', actor)
   	group
	end

	def self.ensure_queue
		return unless ENV['FEATURES_DEMO_GROUPS']
		existing_ids = Redis::List.new('demo_group_ids').value.select { |id| Group.where(id: id).exists? }
		Redis::List.new('demo_group_ids').clear
		Redis::List.new('demo_group_ids').unshift(*existing_ids) if existing_ids.any?
		refill_queue
	end

	def self.generate_demo_groups
		Demo.where("demo_handle IS NOT NULL").each do |template|
			Group.where(handle: template.demo_handle).update_all(handle: nil)
	    RecordCloner.new(recorded_at: template.recorded_at)
									.create_clone_group_for_public_demo(template.group, template.demo_handle)
		end
	end
end