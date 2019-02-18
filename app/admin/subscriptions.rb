ActiveAdmin.register Subscription do
  actions :new, :create, :index, :show, :edit, :update, :destroy

  filter :kind

  index do
    column :plan
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
    end
  end

  form do |f|
    inputs 'Subscription' do
      input :kind, as: :select, collection: Subscription::KINDS
      input :plan, as: :select, collection: Subscription::PLAN_NAMES
      input :payment_method, as: :select, collection: Subscription::PAYMENT_METHODS
      input :expires_at
      input :chargify_subscription_id, label: "Chargify Subscription Id"
      input :owner_id, label: "Owner Id"
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit!
    end
  end
end
