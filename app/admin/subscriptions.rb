ActiveAdmin.register Subscription do
  includes :groups
  actions :new, :create, :index, :show, :edit, :update, :destroy

  filter :chargify_subscription_id
  filter :expires_at
  filter :payment_method
  filter :plan
  filter :state

  index do
    column :plan
    column 'Groups' do |subscription|
      if subscription.groups.any?
        subscription.groups.map { |group| link_to(group.name, admin_group_path(group)) }
      else
        nil
      end
    end
    column :state
    column :expires_at
    column :payment_method
    column :chargify_subscription_id
    column :owner
    actions
  end

  show do
    attributes_table do
      row :id
      row :plan
      row :state
      row :expires_at
      row :chargify_subscription_id do |subscription|
        if subscription.chargify_subscription_id
          link_to subscription.chargify_subscription_id, "http://#{ENV['CHARGIFY_APP_NAME']}.chargify.com/subscriptions/#{subscription.chargify_subscription_id}", target: '_blank'
        end
      end
      row :payment_method
      row :owner
      row :groups do |subscription|
        subscription.groups.map do |group|
          link_to group.name, admin_group_path(group.id)
        end.join(', ').html_safe
      end
      row :max_threads
      row :max_members
      row :max_orgs
    end

    panel("Refresh chargify") do
      if subscription.chargify_subscription_id
        form action: refresh_admin_subscription_path(subscription), method: :post do |f|
          f.input type: :submit, value: "refresh chargify"
        end
      else
        "no chargify subscription to refresh"
      end
    end
  end

  form do |f|
    inputs 'Subscription' do
      input :plan, as: :select, collection: SubscriptionService::PLANS.keys
      input :payment_method, as: :select, collection: Subscription::PAYMENT_METHODS
      input :state, as: :select, collection: ['active', 'canceled']
      input :expires_at
      input :max_threads
      input :max_members
      input :max_orgs
      input :chargify_subscription_id, label: "Chargify Subscription Id"
      input :owner_id, label: "Owner Id"
    end
    f.actions
  end

  member_action :refresh, :method => :post do
    subscription = Subscription.find(params[:id])
    SubscriptionService.update(subscription: subscription,
                               params: SubscriptionService.chargify_get(subscription.chargify_subscription_id))
    redirect_to [:admin, subscription]
  end

  controller do
    def permitted_params
      params.permit!
    end
  end
end
