ActiveAdmin.register Subscription do
  actions :new, :index, :show, :edit
  filter :amount
  filter :created_at

  index do
    column :group
    column :kind
    column :trial_created_at
    column :expires_at
    column :activated_at
    column :plan
    actions
  end

  member_action :update, :method => :put do
    subscription = Subscription.find(params[:id])
    subscription.amount = params[:subscription][:amount]
    subscription.save
    redirect_to admin_subscription_url, :notice => "Subscription updated"
  end
end
