class PollTemplatesController < ApplicationController
  # TODO remove this file
  def dump_i18n
    group = load_and_authorize :group, :export
    templates = {}
    PollTemplate.where(group_id: group.id).order(:position).each do |pt|
      templates = templates.merge(pt.dump_i18n)
    end
    render plain: templates.to_yaml, layout: false, template: nil
  end
end