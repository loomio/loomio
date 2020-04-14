class GroupSurveyService

  def self.create(params:, actor:)
    group = Group.find(params[:group_id])
    actor.ability.authorize! :create, group
    survey = GroupSurvey.find_or_create_by(group_id: params[:group_id])
    survey.update!(params)
  end
end
