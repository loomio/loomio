class ThreadTemplatesController < ApplicationController
	def dump_i18n_yaml
		@discussion_template = DiscussionTemplate.find_by(id: params[:id], group_id: current_user.adminable_group_ids)
		render plain: @discussion_template.dump_i18n_yaml, layout: false, template: nil
	end
end