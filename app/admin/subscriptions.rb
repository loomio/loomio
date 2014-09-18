ActiveAdmin.register Subscription do
  actions :index, :show, :edit
  filter :group_id
  filter :amount
  filter :created_at
  scope :non_zero
  scope :zero

  index do
    column :group_id
    column :group do |s|
      Group.find(s.group_id).name
    end
    column :amount
    column :created_at
    column :updated_at
    actions
  end

  member_action :update, :method => :put do
    subscription = Subscription.find(params[:id])
    subscription.amount = params[:subscription][:amount]
    subscription.save
    redirect_to admin_subscription_url, :notice => "Subscription updated"
  end
end