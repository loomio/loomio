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

  show do
    h3 cohort.id
    div do
      h2 'joined'
      ul do
        cohort.organisations.each do |group|
          li do
            a(href: admin_group_path(group)) do
              group.name
            end
          end
        end
      end
    end
  end

  controller do
    def permitted_params
      params.permit!
    end
  end


end
