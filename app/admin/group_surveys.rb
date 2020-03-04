ActiveAdmin.register GroupSurvey do
  permit_params :group_id, :category, :location, :size, :declaration, :purpose, :usage, :referrer, :role, :website, :misc

  index do
    column :id
    column 'Group Id', :group_id
    column 'Group Name' do |survey|
      group = Group.find(survey.group_id)
      link_to(group.name, admin_group_path(group))
    end
    column :category
    column :location
    column :size
    column :declaration
    column :purpose
    column :usage
    column :referrer
    column :role
    column :website
    column :misc
    # actions
  end
end
