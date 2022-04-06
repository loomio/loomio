class TemplateService
	def self.generate_demo_groups
		Template.where("demo_handle IS NOT NULL").each do |template|
			Group.where(handle: template.demo_handle).update_all(handle: nil)
	    RecordCloner.new(recorded_at: template.recorded_at)
									.create_clone_group_for_public_demo(template.record, template.demo_handle)
		end
	end
end