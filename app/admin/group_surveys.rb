ActiveAdmin.register GroupSurvey do
  includes :group, :subscription

  permit_params :group_id, :category, :location, :size, :declaration, :purpose, :usage, :referrer, :role, :website, :misc

  actions :index, :show, :new, :edit, :update, :create

  index do
    column :id
    column :group_id
    column 'Group Name' do |survey|
      link_to(survey.group.name, admin_group_path(survey.group)) if survey.group
    end
    column 'Subscription Plan' do |survey|
      link_to(survey.subscription.plan, admin_subscription_path(survey.subscription)) if survey.subscription
    end
    column 'Subscription State' do |survey|
      link_to(survey.subscription.state, admin_subscription_path(survey.subscription)) if survey.subscription
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
    actions
  end

  csv do
    column :id
    column :group_id
    column 'Group Name' do |survey|
      survey.group.name  if survey.group
    end
    column 'Subscription Plan' do |survey|
      survey.subscription.plan if survey.subscription
    end
    column 'Subscription State' do |survey|
      survey.subscription.state if survey.subscription
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
  end
end
