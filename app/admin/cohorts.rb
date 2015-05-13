ActiveAdmin.register Cohort do
  action_item :tag_groups do
    link_to 'Tag groups', tag_groups_admin_cohorts_path, method: :post
  end

  collection_action :tag_groups, method: :post do
    CohortService.tag_groups
    redirect_to admin_cohorts_path
  end

  index do
    column :id
    column :start_on
    column :end_on
    column :groups_count
    actions
  end

  controller do
    def permitted_params
      params.permit!
    end
  end


end
