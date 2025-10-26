ActiveAdmin.register ForwardEmailRule do
  actions :new, :create, :edit

  filter :handle
  filter :email

  controller do
    def permitted_params
      params.permit!
    end
  end

  form do |f|
    f.inputs "Details" do
      f.input :handle
      f.input :email
    end
    f.actions
  end

  actions :index, :show, :new, :edit, :update, :create, :destroy

  member_action :destroy, :method => :delete do
    ForwardEmailRule.find(params[:id]).destroy!
    redirect_to admin_forward_email_rules_path
  end

  member_action :update, :method => :put do
    ForwardEmailRule.find(params[:id]).update(permitted_params[:forward_email_rule])
    redirect_to admin_forward_email_rule_path(params[:id])
  end
end
