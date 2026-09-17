class Api::B2::SearchController < Api::V1::SearchController
  include Api::B2::AuthenticatesApiKey

  private

  # V1 starts with groups available through membership. B2 also searches
  # public groups, then the shared correlated TopicQuery removes private topics.
  def group_ids
    visible_group_ids = GroupQuery.visible_to(user: current_user, show_public: true).pluck(:id)

    if params[:group_id].present?
      visible_group_ids & [ params[:group_id].to_i ]
    elsif params[:org_id] == '0'
      []
    elsif params[:org_id].present?
      visible_group_ids & Group.find(params[:org_id]).id_and_subgroup_ids
    else
      visible_group_ids
    end
  end
end
