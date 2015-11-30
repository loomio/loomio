ActiveAdmin.register Webhook do

  controller do
    def create
      @webhook = Webhook.new(webhook_params)
      if @webhook.save
        redirect_to admin_webhooks_path
      else
        render :new
      end
    end

    def update
      @webhook = find_resource
      if @webhook.update(webhook_params)
        redirect_to admin_webhooks_path
      else
        render :edit
      end
    end

    def webhook_params
      params.require(:webhook).permit(:id, :hookable_id, :hookable_type, :kind, :uri, event_types: [])
    end
  end

  actions :index, :show, :new, :create, :edit, :update

  filter :hookable_id, label: "Hookable Id"
  filter :hookable_type
  filter :kind
  filter :event_types
  filter :created_at

  show do |webhook|
    attributes_table do
      row :hookable_id
      row :hookable_type
      row :uri
      row :kind
      row :event_types
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Webhooks" do
      f.input :id, :input_html => { disabled: true }
      f.input :hookable_id, label: "Hookable Id"
      f.input :hookable_type
      f.input :uri
      f.input :kind
      f.input :event_types, as: :check_boxes, collection: ['new_discussion', 'new_motion', 'motion_closing_soon', 'motion_closed', 'motion_outcome_created', 'motion_outcome_updated', 'new_vote']
    end
    f.actions
  end
end
