class GroupSurveyService

  def self.create(params:, actor:)
    group = FormalGroup.find(params[:group_id])
    actor.ability.authorize! :create, group
    survey = GroupSurvey.create!(params)
  end
end
