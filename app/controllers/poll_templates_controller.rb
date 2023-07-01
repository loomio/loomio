class PollTemplatesController < ApplicationController
	def dump_i18n_yaml
		@poll_template = PollTemplate.find_by(id: params[:id], group_id: current_user.adminable_group_ids)
		render plain: @poll_template.dump_i18n_yaml, layout: false, template: nil
	end
end