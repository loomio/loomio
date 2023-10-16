class ThreadTemplatesController < ApplicationController
	# TODO remove this file
	def dump_i18n
    @group = load_and_authorize(:group, :export)
    templates = {}
    DiscussionTemplate.where(group_id: @group.id).order(:position).each do |dt|
    	templates = templates.merge(dt.dump_i18n)
    end
		render plain: templates.to_yaml, layout: false, template: nil
	end
end