ActiveAdmin.register GroupSurvey do
  permit_params :group_id, :category, :location, :size, :declaration, :purpose, :usage, :referrer, :role, :website, :misc

  index do
    column :id
    # column 'Group Id', :group_id
    column 'Group Name' do |survey|
      group = Group.find(survey.group_id)
      link_to(group.name, admin_group_path(group))
    end
    column 'Subscription Plan' do |survey|
      group = Group.find(survey.group_id)
      subscription = Subscription.find(group.subscription_id)
      link_to(subscription.plan, admin_subscription_path(subscription))
    end
    column 'Subscription State' do |survey|
      group = Group.find(survey.group_id)
      subscription = Subscription.find(group.subscription_id)
      link_to(subscription.state, admin_subscription_path(subscription))
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
    column :created_at
    column :updated_at
    # actions
  end
end
