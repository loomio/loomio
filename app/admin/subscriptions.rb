ActiveAdmin.register Subscription do
  actions :new, :create, :index, :show, :edit, :update, :destroy

  index do
    column :kind
    column :trial_created_at
    column :expires_at
    column :activated_at
    column :plan
    column :chargify_subscription_id
    column :groups do |subscription|
      subscription.groups.map do |group|
        link_to group.name, admin_group_path(group.id)
      end.join(', ').html_safe
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :kind
      row :expires_at
      row :trial_ended_at
      row :activated_at
      row :chargify_subscription_id do |subscription|
        if subscription.chargify_subscription_id
          link_to subscription.chargify_subscription_id, "http://#{ENV['CHARGIFY_APP_NAME']}.chargify.com/subscriptions/#{subscription.chargify_subscription_id}", target: '_blank'
        end
      end
      row :plan
      row :payment_method
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
      input :activated_at
      input :chargify_subscription_id, label: "Chargify Subscription Id"
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit!
    end
  end
end
