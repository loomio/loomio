ActiveAdmin.register Subscription do
  actions :new, :create, :index, :show, :edit, :update, :destroy
  filter :amount
  filter :created_at

  index do
    column :group
    column :kind
    column :trial_created_at
    column :expires_at
    column :activated_at
    column :plan
    column :chargify_subscription_id
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
        chargify_subscription_link(subscription)
      end
      row :plan
      row :payment_method
    end
  end

  form do |f|
    inputs 'Subscription' do
      input :kind, label: "Kind (paid / trial / gift)"
      input :plan, label: "Plan (loomio-standard-plan / loomio-plus-plan)"
      input :payment_method, label: 'Payment method (chargify / manual / paypal)'
      input :expires_at
      input :activated_at
      input :chargify_subscription_id, label: "Chargify Subscription Id"
      input :group_id, label: "Group Id"
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit!
    end
  end
end
